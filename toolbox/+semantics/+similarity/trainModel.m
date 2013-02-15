function [bestSetting, maxCorr]  = trainModel(MSS, train, weights, params)
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

disp('Training the multimodal combination...');

maxCorr = 0;

for k = 1:numel(params.weightingModes)
    for b = 1:numel(params.betas)
        for j = 1:numel(params.channels)
            scoreIndex = 1;
            for i = 1:numel(train{1})
                concept1 = train{1}{i};
                concept2 = train{2}{i};
                goldScore = train{3}(i);
                if weights.isKey(concept1) == 1 && weights.isKey(concept2) == 1
                    
                    
                    weight1 = (1 - weights(concept1))/b;
                    weight2 = (1 - weights(concept2))/b;
                    
                    if strcmp(params.channels{j}, 'image')
                        weight1 = 1 - weight1;
                        weight2 = 1 - weight2;
                    end
                    
                    scoredPair{scoreIndex} = {concept1 concept2};
                    pairScore = MSS.getWeightedSimilarity(concept1, concept2,...
                        params.similarityMeasure, params.channels{j}, params.weightingModes{k},...
                        [weight1 weight2]);
                    
                    if pairScore ~= -1
                        trainScores(scoreIndex,1) = goldScore;
                        modelScores(scoreIndex,j) = pairScore;
                        scoreIndex = scoreIndex+1;
                    end
                end
            end
        end
        combinedModelScores = 0;
        for c = 1:numel(params.channels)
            combinedModelScores = combinedModelScores + modelScores(:,c);
        end
        tmpCorr = corr(trainScores, combinedModelScores, 'type', 'Spearman');
        
        if tmpCorr > maxCorr
            maxCorr = tmpCorr;
            bestSetting = [k b];
        end
        scoredPairs{j,k,b} = scoredPair;
    end
end











