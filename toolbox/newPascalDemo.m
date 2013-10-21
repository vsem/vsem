%function newPascalDemo(varargin)

% set the demo type to 'tiny' for less computationally expensive settings
configuration.demoType = 'tiny';
opts.dataset = 'pascal' ;
opts.prefix = 'bovw' ;
opts.dataDir = 'data';
opts.lite = true ;
for pass = 1:2
  opts.datasetDir = fullfile(opts.dataDir, opts.dataset) ;
  opts.resultDir = fullfile(opts.dataDir, opts.prefix) ;
  opts.encoderPath = fullfile(opts.resultDir, 'encoder.mat') ;
  opts.diaryPath = fullfile(opts.resultDir, 'diary.txt') ;
  opts.cacheDir = fullfile(opts.resultDir, 'cache') ;
  %opts = vl_argparse(opts,varargin) ;
end

% image dataset and annotation folders
configuration.imagesPath = fullfile(vsemRoot,'data/JPEGImages');
configuration.annotationPath = fullfile(vsemRoot,'data/Annotations');

% number of visual words to compute the visual vocabulary for
configuration.vocabularySize = 100;

% localization tipe, 'global', 'surrounding' or 'object
configuration.localization = 'object';

% % spatial binning (including spatial information from image partitions)
% configuration.squareDivisions = 2;
% configuration.horizontalDivisions = 3;

% tiny settings
if strcmpi(configuration.demoType, 'tiny')
    configuration.vocabularySize = 10;
    % number of images to be used in the creation of visual vocabulary;
    % if limit < 1, no discount is applied
    configuration.vocabularyImageLimit = 50;
    % number of images to calculate the concept representation from; if
    % limit < 1, no discount is applied
    configuration.conceptImageLimit = 20;
end

% dataset object creation
dataset = datasets.VsemDataset(configuration.imagesPath, 'annotationFolder',...
    configuration.annotationPath);

if strcmpi(configuration.demoType, 'tiny')
    annotatedImages = dataset.getAnnotatedImages('imageLimit', ...
        configuration.conceptImageLimit);
else
    annotatedImages = dataset.getAnnotatedImages();
end

imagePaths = annotatedImages.imageData(:,1);
annotations = annotatedImages.imageData(:,2);
conceptList = annotatedImages.conceptList;
clear annotatedImages;


opts.encoderParams = {'type', 'bovw'} ;

vl_xmkdir(opts.cacheDir) ;
diary(opts.diaryPath) ; diary on ;
disp('options:' ); disp(opts) ;

if exist(opts.encoderPath)
  encoder = load(opts.encoderPath) ;
else
  numTrain = 5000 ;
  if opts.lite, numTrain = 10 ; end
  %train = vl_colsubset(find(imdb.images.set <= 2), numTrain, 'uniform') ;
  encoder = trainEncoder(imagePaths, ...
                         opts.encoderParams{:}, ...
                         'lite', opts.lite) ;
  %save(opts.encoderPath, '-struct', 'encoder') ;
  diary off ;
  diary on ;
end

conceptSpace = extractConcepts(encoder, imagePaths, annotations, conceptList);





diary off ;
diary on ;