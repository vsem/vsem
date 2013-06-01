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
configuration.vocabularySize = 256;

% dimensionality reduction of visual feature descriptors
configuration.descriptorDimension = 80;

% localization tipe, 'global', 'surrounding' or 'object
configuration.localization = 'object';

% spatial binning (including spatial information from image partitions)
configure.squareDivisions = 2;
configure.horizontalDivisions = 3;

% tiny settings
if strcmpi(configuration.demoType, 'tiny')
    configuration.vocabularySize = 25;
    % number of images to be used in the creation of visual vocabulary;
    % if limit < 1, no discount is applied
    configuration.vocabularyImageLimit = 40;
    % number of images to calculate the concept representation from; if
    % limit < 1, no discount is applied
    configuration.conceptImageLimit = 15;
    configuration.descriptorDimension = 128;
end


% -------------------------------------------------------------------------
%                                               Concept extraction pipeline
% -------------------------------------------------------------------------


% dataset object creation
dataset = datasets.VsemDataset(configuration.imagesPath, 'annotationFolder',...
    configuration.annotationPath);

% featureExtractor object creation
featureExtractor = vision.features.PhowFeatureExtractor();

% visual feature descriptor dimensionality reduction
if configuration.descriptorDimension ~= 128
    dimensionalityReduction = vision.features.helpers.dimensionality.PCADimensionalityReduction(featureExtractor, configuration.descriptorDimension);
    featureExtractor.phowConfiguration.low_proj = dimensionalityReduction.train(dataset);
end

% visual vocabulary generator object and visual vocabulary creation
if strcmpi(configuration.demoType, 'tiny')
    % image discount
    GMMVocabulary = vision.vocabulary.GMMVocabulary('voc_size',...
        configuration.vocabularySize, 'trainimage_limit',...
        configuration.vocabularyImageLimit);
else
    % no image discount
    GMMVocabulary = vision.vocabulary.GMMVocabulary('voc_size',...
        configuration.vocabularySize);
end

vocabulary = GMMVocabulary.trainVocabulary(dataset.getImagesPaths(), ...
    featureExtractor);

% histogram and concept extractor objects creation and concept extraction
histogramExtractor = vision.histograms.bovwhistograms.VsemHistogramExtractor(...
    featureExtractor, vocabulary, 'encoding', 'fisher', 'localization',...
    configuration.localization, 'quad_divs', configure.squareDivisions,...
    'horiz_divs', configure.horizontalDivisions);

conceptExtractor = concepts.extractor.VsemConceptsExtractor('subbin_norm_type', 'l2', 'norm_type', 'l2', 'kermap', 'hellinger', 'post_norm_type', 'l2');

if strcmpi(configuration.demoType, 'tiny')
    % image discount
    concepts = conceptExtractor.extractConcepts(dataset, histogramExtractor,...
        'imageLimit', configuration.conceptImageLimit);
else
    % no image discount
    concepts = conceptExtractor.extractConcepts(dataset, histogramExtractor);
end
