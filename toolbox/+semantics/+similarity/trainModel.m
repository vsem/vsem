function [f, beta, trainCorr]  = trainModel(MSS, train, weights, params)
% TRAINMODEL  Train a multimodal semantic space
%   [WEIGHTINGMODE, BETA, TRAINCORR] = TRAINMODEL(MSS, TRAIN, WEIGHTS, PARAMS) learns the
%   optimal parametrization of a multiomdal semantic model on the given
%   train dataset for semantic similarity.
%
%   In particular, it learns f and beta from the forumla:
%
%   reweightedSim(w1, w2) = sim(w1,w2) * f(rs(w1)/beta, rs(w2)/beta)
%
%   where
%
%   sim = similarity measure for w1 and w2 (e.g., cosine similarity)
%   f = mean,min,max
%   rs = reweighting score for the given word (e.g., imageability score)
%   beta = models the impact of rs in the reweighting
%
%   MSS:: semantics.representation.MultimodalSemanticSpace
%     This is the multimodal semantic space to be trained
%
%   train:: the training data
%
%   weights:: the weights associated to each of the target concepts
%     for the reweighting
%
%   params:: the parameters for computing the semantic similarity 
%

% Authors: A1

% AUTORIGHTS
%
% This file is part of VSEM, available under the terms of the
% GNU GPLv2, or (at your option) any later version.
% -------------------------------------------------------------------
%
% -------------------------------------------------------------------

trainCorr = 0;
init = true;
% cycle over the weighting  modes, typicall mean,min,max
for k = 1:numel(params.similarity.weightingModes)
    % cycle over betas (the impact factors of the reweighting function)
    for b = 1:numel(params.similarity.betas)
        % cycle over the channels, typically text and image for a
        % multimodal semantic space
        for j = 1:numel(params.similarity.channels)
            scoreIndex = 1;
            for i = 1:numel(train.data{1})
                % Note that a dataset for computing semantic similarity is
                % constituted of a list of word pairs together with their
                % associated gold scores. That's what train.data contains.
                % See [1] for a traiditional semantic similarity dataset.
                concept1 = train.data{1}{i};
                concept2 = train.data{2}{i};
                goldScore = train.data{3}(i);
                % check if both concepts have a reweighting weight
                if weights.isKey(concept1) == 1 && weights.isKey(concept2) == 1
                    weight1 = (1 - weights(concept1))/b;
                    weight2 = (1 - weights(concept2))/b;  
                    if strcmp(params.similarity.channels{j}, 'image')
                        % Since a reweighting score assumes that the two
                        % channels are complementary, the sum of the two
                        % weight components (one for reweighting 
                        %the text channel and the other tor reweighting 
                        % the image channel) must be 1.
                        weight1 = 1 - weight1;
                        weight2 = 1 - weight2;
                    end
                    % the similarity score for the given pair
                    pairScore = MSS.getWeightedSimilarity(concept1, concept2,...
                        params.similarity.similarityMeasure, params.similarity.channels{j},...
                        params.similarity.weightingModes{k},...
                        [weight1 weight2]);  
                    if pairScore ~= -1
                        % Populate once for all the gold scores for those
                        % word pairs for which a similarity score was
                        % succesfully computed.
                        if init
                            trainScores(scoreIndex,1) = goldScore;
                        end
                        % populate the model scores
                        modelScores(scoreIndex,j) = pairScore;
                        scoreIndex = scoreIndex+1;
                    end    
                end
            end
            init = false;
        end
        combinedModelScores = 0;
        for c = 1:numel(params.similarity.channels)
            % Combine the similarity scores provided by the two channels
            % independently. This is typycally called late fusion.
            combinedModelScores = combinedModelScores + modelScores(:,c);
        end
        % compute the Spearman correlation of the combined model scores
        tmpCorr = corr(trainScores, combinedModelScores, 'type', 'Spearman');
        % update the best correlation and the parameter setting with which
        % it was obtained
        if tmpCorr > trainCorr
            trainCorr = tmpCorr;
            f = params.similarity.weightingModes{k};
            beta = b;
        end
    end   
end