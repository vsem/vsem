function [trainedWeigthingMode, trainedBeta, maxCorr]  = trainModel(MSS, train, weights, params)
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
init = true;
for k = 1:numel(params.similarity.weightingModes)
    for b = 1:numel(params.similarity.betas)
        for j = 1:numel(params.similarity.channels)
            scoreIndex = 1;
            for i = 1:numel(train.data{1})
                concept1 = train.data{1}{i};
                concept2 = train.data{2}{i};
                goldScore = train.data{3}(i);
                if weights.isKey(concept1) == 1 && weights.isKey(concept2) == 1
                    weight1 = (1 - weights(concept1))/b;
                    weight2 = (1 - weights(concept2))/b;
                    
                    if strcmp(params.similarity.channels{j}, 'image')
                        weight1 = 1 - weight1;
                        weight2 = 1 - weight2;
                    end
                    
                    pairScore = MSS.getWeightedSimilarity(concept1, concept2,...
                        params.similarity.similarityMeasure, params.similarity.channels{j}, params.similarity.weightingModes{k},...
                        [weight1 weight2]);
                    
                    
                    if pairScore ~= -1
                        if init
                            trainScores(scoreIndex,1) = goldScore;
                        end
                        modelScores(scoreIndex,j) = pairScore;
                        scoreIndex = scoreIndex+1;
                    end
                    
                end
            end
            init = false;
        end
        combinedModelScores = 0;
        for c = 1:numel(params.similarity.channels)
            combinedModelScores = combinedModelScores + modelScores(:,c);
        end
        tmpCorr = corr(trainScores, combinedModelScores, 'type', 'Spearman');
        
        if tmpCorr > maxCorr
            maxCorr = tmpCorr;
            trainedWeigthingMode = params.similarity.weightingModes{k};
            trainedBeta = b;
        end
    end
    
end











