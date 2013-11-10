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
%    Warning: Running the whole demo might be a slow process. Using parallel
%    MATLAB and several cores/machiens is suggested.
%

% Author: Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

% set the demo type to 'tiny' for less computationally expensive settings
opts.demoType = 'tiny';

data.prefix = 'bovw';
data.dir = 'data';
for pass = 1:2
  data.resultDir = fullfile(data.dir, data.prefix);
  data.encoderPath = fullfile(data.resultDir, 'encoder.mat');
  data.diaryPath = fullfile(data.resultDir, 'diary.txt');
  data.cacheDir = fullfile(data.resultDir, 'cache');
end

% image dataset and annotation folders
opts.datasetParams = {...
    'annotationType', 'completeAnnotation', ...
    'imageDir', fullfile(vsem_root, data.dir, 'JPEGImages'), ...
    'annotations', fullfile(vsem_root, data.dir, 'Annotations')};


opts.encoderParams = {...
  'type', 'bovw', ...
  'numWords', 4096, ...
  'layouts', {'1x1'}, ...
  'geometricExtension', 'xy', ...
  'numPcaDimensions', 100, ...
  'whitening', true, ...
  'whiteningRegul', 0.01, ...
  'renormalize', true, ...
  'extractorFn', @(x) getDenseSIFT(x, ...
                                   'step', 4, ...
                                   'scales', 2.^(1:-.5:-3))};
                               
opts.conceptExtractParams = {'localization', 'global',...
                             'verbose', false};       

% tiny settings
if strcmpi(opts.demoType, 'tiny')
    opts.encoderParams = {...
        'type', 'bovw', ...
        'numWords', 128, ...
        'extractorFn', @(x) getDenseSIFT(x, ...
                                         'step', 4, ...
                                         'scales', 2.^(1:-.5:-3))};
    opts.vocabularySize = 10;
    % number of images to be used in the creation of visual vocabulary;
    % if limit < 1, no discount is applied
    opts.vocabularyImageLimit = 10;
    % maximum number of images used
    opts.imageLimit = 10;
end

% dataset object creation
[imagePaths, annotations, conceptList] = ...
    readDataset(opts.datasetParams{:})

if strcmpi(opts.demoType, 'tiny')
    [imagePaths, annotations] = ...
        randomDatasetSubset(opts.imageLimit, imagePaths, annotations);
end

vl_xmkdir(data.cacheDir);
diary(data.diaryPath); diary on;
disp('options:' ); disp(opts);

% if exist(data.encoderPath)
%  encoder = load(data.encoderPath);
% else
  encoder = trainEncoder(imagePaths, ...
                         opts.encoderParams{:});
  save(data.encoderPath, '-struct', 'encoder');
  fprintf('Traning encoder done!\n');
  diary off;
  diary on;
%end


conceptSpace = extractConcepts(encoder, imagePaths, annotations, ...
                               conceptList, opts.conceptExtractParams{:});
                           
% computing similarity RHO with similarity extractor
[RHO, PVAL] = runSimilarityBenchmark(conceptSpace, 'pascal');

% printing results
fprintf('Relatedness RHO: %4.2f%%\n',RHO*100);
fprintf('Significance (p value) of %4.3f on the Pascal similarity benchmark.\n', PVAL);


diary off;
diary on;
