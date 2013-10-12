% -------------------------------------------------------------------------
%                                                    Configuration settings
% -------------------------------------------------------------------------


% adds paths to Matlab's search path
vsemStartup

% set the demo type to 'tiny' for less computationally expensive settings
configuration.demoType = 'tiny';

% image dataset and annotation folders
configuration.imagesPath = fullfile(vsemRoot,'data/JPEGImages');
configuration.annotationPath = fullfile(vsemRoot,'data/Annotations');

% number of visual words to compute the visual vocabulary for
configuration.vocabularySize = 100;

% localization tipe, 'global', 'surrounding' or 'object
configuration.localization = 'object';

% turning off the spatial binning
configuration.turnMeOff = true;

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


% -------------------------------------------------------------------------
%                                               Concept extraction pipeline
% -------------------------------------------------------------------------


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

% featureExtractor object creation
featureExtractor = vision.features.PhowFeatureExtractor();

% visual vocabulary generator object and visual vocabulary creation
if strcmpi(configuration.demoType, 'tiny')
    % image discount
    KmeansVocabulary = vision.vocabulary.KmeansVocabulary('voc_size',...
        configuration.vocabularySize, 'trainimage_limit',...
        configuration.vocabularyImageLimit);
else
    % no image discount
    KmeansVocabulary = vision.vocabulary.KmeansVocabulary('voc_size',...
        configuration.vocabularySize);
end

vocabulary = KmeansVocabulary.trainVocabulary(imagePaths,...
    featureExtractor);

% histogram and concept extractor objects creation and concept extraction
histogramExtractor = vision.histograms.bovwhistograms.VsemHistogramExtractor(...
    featureExtractor, vocabulary, 'localization', configuration.localization,...
    'turnMeOff', configuration.turnMeOff);

conceptExtractor = concepts.extractor.VsemConceptsExtractor();

conceptSpace = conceptExtractor.extractConcepts(histogramExtractor, ...
    imagePaths, annotations, conceptList);

% reweighting concept matrix
%conceptSpace = conceptSpace.reweight('reweightingFunction', @concepts.space.transformations.reweighting.pmiReweight);

% computing similarity score with similarity extractor
[score, pValue] = benchmarks.runBenchmark(conceptSpace, 'pascal');

% printing results
fprintf('The obtained visual concepts performed with a score of %4.2f%% and a significance (p value) of %4.3f on the Pascal similarity benchmark.\n',score*100, pValue);
