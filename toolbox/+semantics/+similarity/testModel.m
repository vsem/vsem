function [testCorr testedData] = testModel(MSS, test, weights, params)
%
%
%
%
%
%
%
%

% -------------------------------------------------------------------
%
% -------------------------------------------------------------------

disp('Testing the multimodal combination...');

maxCorr = 0;


for j = 1:numel(params.similarity.channels)
    scoreIndex = 1;
    for i = 1:numel(test.data{1})
        concept1 = test.data{1}{i}; % transform to test.data
        concept2 = test.data{2}{i};
        goldScore = test.data{3}(i);
        if weights.isKey(concept1) == 1 && weights.isKey(concept2) == 1
            
            
            weight1 = (1 - weights(concept1))/params.similarity.trainedBeta;
            weight2 = (1 - weights(concept2))/params.similarity.trainedBeta;
            
            if strcmp(params.similarity.channels{j}, 'image')
                weight1 = 1 - weight1;
                weight2 = 1 - weight2;
            end
            
            pairScore = MSS.getWeightedSimilarity(concept1, concept2,...
                params.similarity.similarityMeasure, params.similarity.channels{j}, params.similarity.trainedWeigthingMode,...
                [weight1 weight2]);
            
            if pairScore ~= -1
                testScores(scoreIndex,1) = goldScore;
                modelScores(scoreIndex,j) = pairScore;
                scoredPairs{scoreIndex} = {concept1 concept2};
                scoreIndex = scoreIndex+1;
            end
        end
    end
end
combinedModelScores = 0;
for c = 1:numel(params.similarity.channels)
    combinedModelScores = combinedModelScores + modelScores(:,c);
end

testCorr = corr(testScores, combinedModelScores, 'type', 'Spearman');
testedData{1} = scoredPairs;
testedData{2} = combinedModelScores;














