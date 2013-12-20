%function bovwDemo()
% bovwDemo   Run visual concepts demo
%    The bovwDemo runs the visual concept construction pipeline
%    on the Pascal dataset sample which comes together vith VSEM.
%
%    By default, the demo runs with a lite option turned on. This
%    quickly runs the pipeline with a lighter option configuration.
%    This is used only for testing; to run the actual demo,
%    set the lite variable to false.
%

% Author: Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


% --------------------------------------------------------------------
%                                                        Setup options
% --------------------------------------------------------------------

% set the demo type to 'tiny' for less computationally expensive settings
opts.demoType = 'tiny';
% if true it reuses previously computed and saved data
opts.reuseSavedData = false;
data.prefix = 'bovw';
data.dir = 'data';
opts.randSeed = 1 ;

for pass = 1:2
    data.resultDir = fullfile(data.dir, data.prefix);
    data.imagePathsPath = fullfile(data.resultDir, 'imagePaths.mat');
    data.annotationsPath = fullfile(data.resultDir, 'annotations.mat');
    data.conceptListPath = fullfile(data.resultDir, 'conceptList.mat');
    data.encoderPath = fullfile(data.resultDir, 'encoder.mat');
    data.conceptSpacePath = fullfile(data.resultDir, 'conceptSpaceCia.mat');
    data.diaryPath = fullfile(data.resultDir, 'diary.txt');
    data.cacheDir = fullfile(data.resultDir, 'cache');
end

% image dataset and annotation folders
opts.datasetParams = {...
    'maxNumTrainImagesPerConcept', 100, ...,
    'inputFormat', 'completeAnnotation', ...
    'imageDir', fullfile(vsem_root, data.dir, 'images'), ...
    'annotations', fullfile(vsem_root, data.dir, 'annotations')};

% feature extraction and encoding parameters
opts.encoderParams = {...
    'maxNumTrainImages', 10000, ...
    'type', 'bovw', ...
    'numWords', 4096, ...
    'layouts', {'1x1', '3x1'}, ...
    'geometricExtension', 'xy', ...
    'numPcaDimensions', 100, ...
    'whitening', true, ...
    'whiteningRegul', 0.01, ...
    'renormalize', true, ...
    'extractorFn', @(x) getDenseSIFT(x, ...
    'step', 4, ...
    'scales', 2.^(1:-.5:-3))};

% concept extraction parameters
opts.conceptExtractParams = {...
    'localization', 'object',...
    'verbose', false};

% concept space tranformation parameters
opts.transformations = 'lmi';

% tiny settings
if strcmpi(opts.demoType, 'tiny')
    opts.encoderParams = {...
        'type', 'bovw', ...
        'numWords', 128, ...
        'layouts', {'1x1', '3x3'}, ...
        'extractorFn', @(x) getDenseSIFT(x, ...
        'step', 4, ...
        'scales', 2.^(1:-.5:-3))};
    % maximum number of images used
    opts.imageLimit = 10;
end

% color extractor
if strcmpi(opts.demoType, 'color')
    opts.encoderParams = {...
        'type', 'bovw', ...
        'numWords', 128, ...
        'extractorFn', @(x) getColorFeatures(x), ...
        'readImageFn', @(x) readColorImage(x)};
    % maximum number of images used
    opts.imageLimit = 50;
end

randn('state',opts.randSeed) ;
rand('state',opts.randSeed) ;
vl_twister('state',opts.randSeed) ;


% --------------------------------------------------------------------
%                                                        Read data set
% --------------------------------------------------------------------

if exist(data.imagePathsPath) & exist(data.annotationsPath)...
        & exist(data.conceptListPath) & opts.reuseSavedData
    % load dataset
    imagePaths = load(data.imagePathsPath);
    annotations = load(data.annotationsPath);
    conceptList = load(data.conceptListPath);
else
    % read dataset
    [imagePaths, annotations, conceptList] = ...
        readDataset(opts.datasetParams{:});
    save(data.imagePathsPath, 'imagePaths');
    save(data.annotationsPath, 'annotations');
    save(data.conceptListPath, 'conceptList');
    fprintf('Reading dataset done!\n\n');
    diary off;
    diary on;
end

if strcmpi(opts.demoType, 'tiny')
    [imagePaths, annotations] = ...
        randomDatasetSubset(opts.imageLimit, imagePaths, annotations);
end

% --------------------------------------------------------------------
%                                                        Train encoder
% --------------------------------------------------------------------

vl_xmkdir(data.cacheDir);
diary(data.diaryPath); diary on;

if exist(data.encoderPath) & opts.reuseSavedData
    encoder = load(data.encoderPath);
else
    encoder = trainEncoder(imagePaths, ...
        opts.encoderParams{:});
    save(data.encoderPath, '-struct', 'encoder');
    fprintf('Traning encoder done!\n\n');
    diary off;
    diary on;
end


% --------------------------------------------------------------------
%                                                     Extract concepts
% --------------------------------------------------------------------

% extract the concept space
conceptSpace = extractConcepts(encoder, imagePaths, annotations, ...
    conceptList, opts.conceptExtractParams{:});

% compute transformations
switch opts.transformations
    case 'pmi'        
        % compute pointwise mutual information
        conceptSpace.conceptMatrix = pmiReweight(conceptSpace.conceptMatrix);        
    case 'lmi'
        % compute local mutual information
        conceptSpace.conceptMatrix = lmiReweight(conceptSpace.conceptMatrix);
end

% save the concept space
save(data.conceptSpacePath, 'conceptSpace');
fprintf('Extracting concepts done!\n\n');
diary off;
diary on;


% --------------------------------------------------------------------
%                                             Run similarity benchmark
% --------------------------------------------------------------------

% compute similarity RHO with similarity extractor
[RHO, PVAL, coverage] = runSimilarityBenchmark(conceptSpace, 'pascal');

% print results
fprintf('----------------------------------------------------\n');
fprintf('           PASCAL SIMILARITY BENCHMARK\n')
fprintf('           Coverage: %d of %d concept pairs.\n',coverage(1), coverage(2));
fprintf('           Relatedness (RHO): %4.2f%%.\n',RHO*100);
fprintf('           Significance (P-VALUE): %4.3f.\n', PVAL);
fprintf('----------------------------------------------------\n');

diary off;
diary on;
