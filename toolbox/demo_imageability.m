
function demo_imageability

% DEMO_IMAGEABILITY  Demo: REWEIGHTING: reweight conceptBovwHistograms
% according to the imageability score of each concept
%
%
%
%
%
%


% -------------------------------------------------------------------
%                                                 Parse the arguments
% -------------------------------------------------------------------

config.path.dataDir = '/Users/eliabruni/work/abstractness/imageability-test/data';


% the image-based semantic representation
config.path.imageVectors = fullfile(config.path.dataDir, 'matrices/imageVectors.txt');
config.path.imageConcepts = fullfile(config.path.dataDir, 'matrices/imageConcepts.txt');

% the text-based semantic representation
config.path.textVectors = fullfile(config.path.dataDir, 'matrices/textVectors.txt');
config.path.textConcepts = fullfile(config.path.dataDir, 'matrices/textConcepts.txt');

% the file containing the new weighting scheme
config.path.imageabilityScores = fullfile(config.path.dataDir, 'scores/abstrScores.mat');

config.path.trainData = fullfile(config.path.dataDir, 'train/wordsim.csv');
config.path.testData{1} = fullfile(config.path.dataDir, 'train/wordsim.csv');
config.path.testData{2} = fullfile(config.path.dataDir, 'train/wordsim.csv');


% --------------------------------------------------------------------
%                                                       Setup the data
% --------------------------------------------------------------------

% load text-based semantic representation
textConcepts = readConcepts(config.path.textConcepts);
textVectors = dlmread(config.path.textVectors);

% load image-based semantic rpresentation
imageConcepts = readConcepts(config.path.imageConcepts);
imageVectors = dlmread(config.path.imageVectors);

% load abstractness scores
scores = load(config.path.imageabilityScores);
config.data.imageabilityScores = scores.abstrScores;

% filter out the concepts that are not contained by both channels
[commonConcepts, textVectors, imageVectors] = ...
    semantics.representation.utility.filterChannels(textConcepts,...
    textVectors, imageConcepts, imageVectors);

% construct the multimodal semantic space
MSS = semantics.representation.MultimodalSemanticSpace(commonConcepts,...
    textVectors, imageVectors);


% --------------------------------------------------------------------
%                                  Train the multimodal semantic space
% --------------------------------------------------------------------

disp('Training the multimodal combination...');

[config.train.data, fileName] = parseData(config.path.trainData);

[f, beta, trainCorr] = semantics.similarity.trainModel(MSS,...
    config.train, config.data.imageabilityScores);

fprintf('The model obtained a max correlation of %s on the training data %s. \n',...
    num2str(trainCorr), fileName);

config.test.options = {'fMode', f, 'beta', beta};

% --------------------------------------------------------------------
%                                  Test the multimodal semantic space
% --------------------------------------------------------------------

disp('Testing the multimodal combination...');

for i = 1:numel(config.path.testData)
    
    [config.test.data, fileName] = parseData(config.path.testData{i});
    
    [testCorr testedData] = semantics.similarity.testModel(MSS, config.test,... 
        config.data.imageabilityScores, config.test.options{:});
    
    fprintf('The model obtained a correlation of %s on the testing data %s. \n',... 
        num2str(testCorr), fileName);
    
end


% Auxiliary functions

% -------------------------------------------------------------------------
function concepts = readConcepts(filePath)
% -------------------------------------------------------------------------

fid1 = fopen(filePath, 'rt');
conceptsScan = textscan(fid1, '%s', 'Delimiter',' ');
concepts = conceptsScan{:};
fclose(fid1);


% -------------------------------------------------------------------------
function [data, fileName] = parseData(filePath)
% -------------------------------------------------------------------------

[concepts1, concepts2, goldScores] = textread(filePath, '%s%s%f','delimiter',';');
data{1} = concepts1;
data{2} = concepts2;
data{3} = goldScores;

[drop fileName drop] = fileparts(filePath);


