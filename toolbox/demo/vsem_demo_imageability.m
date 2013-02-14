% VS_DEMO_IMAGEABILITY  Demo: REWEIGHTING: reweight conceptBovwHistograms
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

conf.paths.dataDir = '/Users/eliabruni/work/abstractness/imageability-test/data' ;


% the image-based semantic representation
config.paths.imageVectors = fullfile(conf.paths.dataDir, 'imageVectors.txt') ;
config.paths.imageConcepts = fullfile(conf.paths.dataDir, 'imageConcepts.txt') ;

% the text-based semantic representation
config.paths.textVectors = fullfile(conf.paths.dataDir, 'textVectors.txt') ;
config.paths.textConcepts = fullfile(conf.paths.dataDir, 'textConcepts.txt') ;

% the file containing the new weighting scheme
config.paths.imageabilityScores = fullfile(conf.paths.dataDir, 'abstrScores.mat') ;

% the file containing the concept pair for which a semantic similarity measure has to be computed
config.paths.conceptPairs = fullfile(conf.paths.dataDir, 'wordsim353_naturalform.pairs') ;

% output
config.paths.meanSimilarityScores = fullfile(conf.paths.dataDir, 'meanSimilarityScores.txt') ;
config.paths.maxSimilarityScores = fullfile(conf.paths.dataDir, 'maxSimilarityScores.txt') ;
config.paths.minSimilarityScores = fullfile(conf.paths.dataDir, 'minSimilarityScores.txt') ;


% --------------------------------------------------------------------
%                                                       Setup the data
% --------------------------------------------------------------------

% load text-based semantic representation
fid1 = fopen(config.paths.textConcepts, 'rt') ;
textConceptsScan = textscan(fid1, '%s', 'Delimiter',' ') ;
textConcepts = textConceptsScan{:} ;
textVectors = dlmread(config.paths.textVectors) ;
fclose(fid1) ;

% load image-based semantic rpresentation
fid2 = fopen(config.paths.imageConcepts,'rt') ;
imageConceptsScan = textscan(fid2, '%s', 'Delimiter',' ') ;
imageConcepts = imageConceptsScan{:} ;
imageVectors = dlmread(config.paths.imageVectors) ;
fclose(fid2) ;

% load abstractness scores
abstScores = load(config.paths.imageabilityScores) ;
abstScores = abstScores.abstrScores ;


% load concept pairs for which a semantic similarity measure has to be computed
fid3 = fopen(config.paths.conceptPairs,'r') ;
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


% filter out the concepts that are not contained by both channels
[commonConcepts, textVectors, imageVectors] = semantics.representation.utility.vsem_filterChannels(textConcepts, textVectors, imageConcepts, imageVectors) ;
multimodalSemanticSpace = semantics.representation.MultimodalSemanticSpace(commonConcepts, textVectors, imageVectors) ;
similarityMeasure = 'cosine' ;
weightingModes = {'mean' 'min' 'max'} ;


% --------------------------------------------------------------------
%                                                  Compute similarity 
% --------------------------------------------------------------------

% compute similarity for the text channel
channel = 'text' ;
[textSimilarityScores textPairWithScores] = semantics.similarity.vsem_computeSimilarity(multimodalSemanticSpace, conceptPairs, similarityMeasure, channel, weightingModes, abstScores) ;

% compute similarity for the image channel
channel = 'image' ;
[imageSimilarityScores imagePairWithScores] = semantics.similarity.vsem_computeSimilarity(multimodalSemanticSpace, conceptPairs, similarityMeasure, channel, weightingModes, abstScores) ;

% combine the scores of the two channels
meanMimilarityScores = [textSimilarityScores{1}{:}] + [imageSimilarityScores{1}{:}] ;
minMimilarityScores = [textSimilarityScores{2}{:}] + [imageSimilarityScores{2}{:}] ;
maxMimilarityScores = [textSimilarityScores{3}{:}] + [imageSimilarityScores{3}{:}] ;


meanPairWithScores = textPairWithScores{1} ;
minPairWithScores = textPairWithScores{2} ;
maxPairWithScores = textPairWithScores{3} ;


% --------------------------------------------------------------------
%                                                     Save the results 
% --------------------------------------------------------------------

fid4=fopen(config.paths.meanSimilarityScores,'w') ;
for j = 1:numel(meanMimilarityScores)
    fprintf(fid4,'%s %s %s\n', meanPairWithScores{j}{1},meanPairWithScores{j}{2}, num2str(meanMimilarityScores(j))) ;
end
fclose(fid4) ;

fid5=fopen(config.paths.maxSimilarityScores,'w') ;
for j = 1:numel(maxMimilarityScores)
    fprintf(fid5,'%s %s %s\n', maxPairWithScores{j}{1},maxPairWithScores{j}{2}, num2str(minMimilarityScores(j))) ;
end
fclose(fid5) ;

fid6=fopen(config.paths.minSimilarityScores,'w') ;
for j = 1:numel(minMimilarityScores)
    fprintf(fid6,'%s %s %s\n', minPairWithScores{j}{1},minPairWithScores{j}{2}, num2str(maxMimilarityScores(j))) ;
end
fclose(fid6) ;








