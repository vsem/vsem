%function bovwPascalDemo(varargin)

% set the demo type to 'tiny' for less computationally expensive settings
opts.demoType = 'tiny';
opts.dataset = 'pascal';
opts.prefix = 'bovw';
opts.dataDir = 'data';
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

for pass = 1:2
  opts.datasetDir = fullfile(opts.dataDir, opts.dataset);
  opts.resultDir = fullfile(opts.dataDir, opts.prefix);
  opts.encoderPath = fullfile(opts.resultDir, 'encoder.mat');
  opts.diaryPath = fullfile(opts.resultDir, 'diary.txt');
  opts.cacheDir = fullfile(opts.resultDir, 'cache');
  %opts = vl_argparse(opts,varargin);
end

% image dataset and annotation folders
data.imagesPath = fullfile(vsemRoot,'data/JPEGImages');
data.annotationPath = fullfile(vsemRoot,'data/Annotations');


% % spatial binning (including spatial information from image partitions)
% configuration.squareDivisions = 2;
% configuration.horizontalDivisions = 3;

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
    opts.vocabularyImageLimit = 50;
    % number of images to calculate the concept representation from; if
    % limit < 1, no discount is applied
    opts.conceptImageLimit = 50;
end

% dataset object creation
dataset = datasets.VsemDataset(data.imagesPath, 'annotationFolder', ...
    data.annotationPath);

if strcmpi(opts.demoType, 'tiny')
    annotatedImages = dataset.getAnnotatedImages('imageLimit', ...
        opts.conceptImageLimit);
else
    annotatedImages = dataset.getAnnotatedImages();
end

imagePaths = annotatedImages.imageData(:,1);
annotations = annotatedImages.imageData(:,2);
conceptList = annotatedImages.conceptList;
clear annotatedImages;

vl_xmkdir(opts.cacheDir);
diary(opts.diaryPath); diary on;
disp('options:' ); disp(opts);

%if exist(opts.encoderPath)
%  encoder = load(opts.encoderPath);
%else
  encoder = trainEncoder(imagePaths, ...
                         opts.encoderParams{:});
  save(opts.encoderPath, '-struct', 'encoder');
  fprintf('Traning encoder done!\n');
  diary off;
  diary on;
%end

conceptSpace = extractConcepts(encoder, imagePaths, annotations, ...
                               conceptList, opts.conceptExtractParams{:});

diary off;
diary on;