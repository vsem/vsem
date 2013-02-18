function [f, beta, trainCorr]  = trainModel(MSS, train, weights, varargin)
% TRAINMODEL  Train a multimodal semantic space
%   [WEIGHTINGMODE, BETA, TRAINCORR] = TRAINMODEL(MSS, TRAIN, WEIGHTS, PARAMS) learns the
%   optimal parametrization of a multiomdal semantic model on the given
%   train dataset for semantic similarity.
%
%   In particular, it learns f and beta in the following formula to compute
%   semantic similarity:
%
%   reweightedSim(w1, w2) = sim(w1,w2) * f(weights(w1)/beta, weights(w2)/beta)
%
%   where
%
%   sim = similarity measure for w1 and w2 (e.g., cosine similarity)
%   f = mean,min,max
%   weights = the weight for the given concept (e.g., imageability score)
%   beta = models the impact of rs in the reweighting
%
%   MSS:: semantics.representation.MultimodalSemanticSpace
%     This is the multimodal semantic space to be trained.
%
%   train:: 
%     The training data.
%
%   weights::
%     The weights for computing reweightedSim(w1, w2).
%
%   similarityMeasure:: 'cosine'
%     The type of similarity measure to be computed.
%
%   fModes:: {'mean', 'min', 'max'}
%     The reweighting functions f to use for computing reweightedSim(w1, w2).
%
%   channels:: {'text', 'image'}
%     The channels of the multimodal models.
%
%   betas:: 1:1:10
%     The impact factors to use for computing reweightedSim(w1, w2).
%      
%   correlationType:: 'Spearman' 
%     The correlation measure to use to compare with the gold standard. 
%     The available correlation types are Pearson, Kendall or Spearman.
%

% Authors: A1

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


% -------------------------------------------------------------------
%                                                 Parse the arguments
% -------------------------------------------------------------------

options.similarityMeasure = 'cosine';
options.fModes = {'mean', 'min', 'max'};
options.channels = {'text', 'image'};
options.betas = 1:1:10;
options.correlationType = 'Spearman';

options = vl_argparse(options, varargin);

% -------------------------------------------------------------------
%                                                     Train the model
% -------------------------------------------------------------------

trainCorr = 0;
init = true;
% cycle over the weighting  modes, typically mean,min,max
for k = 1:numel(options.fModes)
    % cycle over betas (the impact factors of the reweighting function)
    for b = 1:numel(options.betas)
        
        % cycle over the two channels text and image
        for j = 1:numel(options.channels)         
            scoreIndex = 1;
            for i = 1:numel(train.data{1})
                % Note that a dataset for computing semantic similarity is
                % constituted of a list of concept pairs together with their
                % associated gold scores. That's what train.data contains.
                % See [1] for a traiditional semantic similarity dataset.
                concept1 = train.data{1}{i};
                concept2 = train.data{2}{i};
                goldScore = train.data{3}(i);
                
                % check if both concepts have a reweighting weight
                if weights.isKey(concept1) == 1 && weights.isKey(concept2) == 1
                    weight1 = (1 - weights(concept1))/b;
                    weight2 = (1 - weights(concept2))/b;  
                    if strcmp(options.channels{j}, 'image')
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
                        options.similarityMeasure, options.channels{j},...
                        options.fModes{k},...
                        [weight1 weight2]);  
                    if pairScore ~= -1
                        % Populate once for all the gold scores for those
                        % concept pairs for which a similarity score was
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
        for c = 1:numel(options.channels)
            % Combine the similarity scores provided by the two channels
            % independently. This is typycally called late fusion.
            combinedModelScores = combinedModelScores + modelScores(:,c);
        end
        
        % compute the correlation of the combined model scores
        tmpCorr = corr(trainScores, combinedModelScores, 'type', options.correlationType);
        % update the best correlation and the parameter setting with which
        % it was obtained
        if tmpCorr > trainCorr
            trainCorr = tmpCorr;
            f = options.fModes{k};
            beta = b;
        end
    end   
end