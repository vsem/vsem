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

options.paths.dataDir = '/Users/eliabruni/work/abstractness/imageability-test/data' ;


% the image-based semantic representation
options.paths.imageVectors = fullfile(options.paths.dataDir, 'matrices/imageVectors.txt') ;
options.paths.imageConcepts = fullfile(options.paths.dataDir, 'matrices/imageConcepts.txt') ;

% the text-based semantic representation
options.paths.textVectors = fullfile(options.paths.dataDir, 'matrices/textVectors.txt') ;
options.paths.textConcepts = fullfile(options.paths.dataDir, 'matrices/textConcepts.txt') ;

% the file containing the new weighting scheme
options.paths.imageabilityScores = fullfile(options.paths.dataDir, 'scores/abstrScores.mat') ;

options.paths.trainData = fullfile(options.paths.dataDir, 'train/wordsim.csv') ;
options.paths.testData = fullfile(options.paths.dataDir, 'train/wordsim.csv') ;

% the file containing the concept pair for which a semantic similarity measure has to be computed
options.paths.conceptPairs = fullfile(options.paths.dataDir, 'wordsim353_naturalform.pairs') ;

% output
options.paths.meanSimilarityScores = fullfile(options.paths.dataDir, 'meanSimilarityScores.txt') ;
options.paths.maxSimilarityScores = fullfile(options.paths.dataDir, 'maxSimilarityScores.txt') ;
options.paths.minSimilarityScores = fullfile(options.paths.dataDir, 'minSimilarityScores.txt') ;


% --------------------------------------------------------------------
%                                                       Setup the data
% --------------------------------------------------------------------

% load text-based semantic representation
fid1 = fopen(options.paths.textConcepts, 'rt') ;
textConceptsScan = textscan(fid1, '%s', 'Delimiter',' ') ;
textConcepts = textConceptsScan{:} ;
textVectors = dlmread(options.paths.textVectors) ;
fclose(fid1) ;

% load image-based semantic rpresentation
fid2 = fopen(options.paths.imageConcepts,'rt') ;
imageConceptsScan = textscan(fid2, '%s', 'Delimiter',' ') ;
imageConcepts = imageConceptsScan{:} ;
imageVectors = dlmread(options.paths.imageVectors) ;
fclose(fid2) ;

% load abstractness scores
scores = load(options.paths.imageabilityScores);
options.data.imageabilityScores = scores.abstrScores;


% load concept pairs for which a semantic similarity measure has to be computed
fid3 = fopen(options.paths.conceptPairs,'r') ;
InputText=textscan(fid3,'%s',4,'delimiter','\n');
block = 1 ;                                         % Initialize block index
while (~feof(fid3))                                   % For each block:   
    InputText=textscan(fid3,'%s',1,'delimiter',' '); % Read header line
    stringInputText1 = num2str(cell2mat(InputText{1})) ;
    conceptPairs{block,1} = stringInputText1 ;
    stringInputText2 = num2str(cell2mat(InputText{1})) ;
    InputText=textscan(fid3,'%s',1,'delimiter',' '); % Read header line
    stringInputText2 = num2str(cell2mat(InputText{1})) ;
    conceptPairs{block,2} = stringInputText2;
    block = block+1 ;
end


[concepts1, concepts2, goldScores] = textread(options.paths.trainData, '%s%s%f','delimiter',';');
options.train.data{1} = concepts1;
options.train.data{2} = concepts2;
options.train.data{3} = goldScores;




% filter out the concepts that are not contained by both channels
[commonConcepts, textVectors, imageVectors] = semantics.representation.utility.filterChannels(textConcepts, textVectors, imageConcepts, imageVectors) ;
MSS = semantics.representation.MultimodalSemanticSpace(commonConcepts, textVectors, imageVectors) ;



% --------------------------------------------------------------------
%                                  Train the multimodal semantic space
% --------------------------------------------------------------------


% TODO:
% TRAIN COMBINATION
% TEST COMBINATION



params.similarity.similarityMeasure = 'cosine';
params.similarity.weightingModes = {'mean', 'min', 'max'};
params.similarity.channels = {'text', 'image'};
params.similarity.betas = 1:1:10;



[params.similarity.trainedWeigthingMode, params.similarity.trainedBeta, maxCorr] = semantics.similarity.trainModel(MSS, options.train, options.data.imageabilityScores, params);



[concepts1, concepts2, goldScores] = textread(options.paths.testData, '%s%s%f','delimiter',';');
options.test.data{1} = concepts1;
options.test.data{2} = concepts2;
options.test.data{3} = goldScores;


[testCorr testedData] = semantics.similarity.testModel(MSS, options.test, options.data.imageabilityScores, params);

fprintf('The model obtained a correlation of %s on the testing data. \n', num2str(testCorr)) ;

[concepts1, concepts2, goldScores] = textread(options.paths.testData, '%s%s%f','delimiter',';');
options.test.data{1} = concepts1;
options.test.data{2} = concepts2;
options.test.data{3} = goldScores;


[testCorr testedData] = semantics.similarity.testModel(MSS, options.test, options.data.imageabilityScores, params);

fprintf('The model obtained a correlation of %s on the testing data. \n', num2str(testCorr)) ;







% % --------------------------------------------------------------------
% %                                                  Compute similarity
% % --------------------------------------------------------------------
%
% disp('Compute similarity for the text channel...');
%
% % compute similarity for the text channel
% channel = 'text' ;
% [textSimilarityScores textPairWithScores] = semantics.similarity.computeSimilarity(MSS, conceptPairs, similarityMeasure, channel, weightingModes, options.data.imageabilityScores) ;
%
% disp('Compute similarity for the image channel...');
%
% % compute similarity for the image channel
% channel = 'image' ;
% [imageSimilarityScores imagePairWithScores] = semantics.similarity.computeSimilarity(MSS, conceptPairs, similarityMeasure, channel, weightingModes, options.data.imageabilityScores) ;
%
% % combine the scores of the two channels
% meanMimilarityScores = [textSimilarityScores{1}{:}] + [imageSimilarityScores{1}{:}] ;
% minMimilarityScores = [textSimilarityScores{2}{:}] + [imageSimilarityScores{2}{:}] ;
% maxMimilarityScores = [textSimilarityScores{3}{:}] + [imageSimilarityScores{3}{:}] ;
%
%
% meanPairWithScores = textPairWithScores{1} ;
% minPairWithScores = textPairWithScores{2} ;
% maxPairWithScores = textPairWithScores{3} ;
%
%
% % --------------------------------------------------------------------
% %                                                     Save the results
% % --------------------------------------------------------------------
%
% fid4=fopen(options.paths.meanSimilarityScores,'w') ;
% for j = 1:numel(meanMimilarityScores)
%     fprintf(fid4,'%s %s %s\n', meanPairWithScores{j}{1},meanPairWithScores{j}{2}, num2str(meanMimilarityScores(j))) ;
% end
% fclose(fid4) ;
%
% fid5=fopen(options.paths.maxSimilarityScores,'w') ;
% for j = 1:numel(maxMimilarityScores)
%     fprintf(fid5,'%s %s %s\n', maxPairWithScores{j}{1},maxPairWithScores{j}{2}, num2str(minMimilarityScores(j))) ;
% end
% fclose(fid5) ;
%
% fid6=fopen(options.paths.minSimilarityScores,'w') ;
% for j = 1:numel(minMimilarityScores)
%     fprintf(fid6,'%s %s %s\n', minPairWithScores{j}{1},minPairWithScores{j}{2}, num2str(maxMimilarityScores(j))) ;
% end
% fclose(fid6) ;








