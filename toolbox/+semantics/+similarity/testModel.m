function [testCorr testedData] = testModel(MSS, test, weights, varargin)
% TESTMODEL  Test a multimodal semantic space
%   [TESTCORR, TESTEDDATA] = TESTMODEL(MSS, TEST, WEIGHTS, PARAMS) tests the
%   given parametrization of a multiomdal semantic model 
%   on the given test dataset for semantic similarity.
%
%   The semantic similarity between two cocnepts is computed with the following 
%   formula:
%
%   reweightedSim(w1, w2) = sim(w1,w2) * f(weights(w1)/beta, weights(w2)/beta)
%
%   where
%
%   sim = similarity measure for w1 and w2 (e.g., cosine similarity)
%
%   f = mean,min,max
%
%   weights = the weight for the given concept (e.g., imageability score)
%
%   beta = models the impact of rs in the reweighting
%
%
%   MSS:: [semantics.representation.MultimodalSemanticSpace]
%     This is the multimodal semantic space to be tested.
%
%   Test:: 
%     The testing data.
%
%   Weights::
%     The weights for computing reweightedSim(w1, w2).
%
%   Channels:: {'text', 'image'}
%     The channels of the multimodal model.
%
%   SimilarityMeasure:: 'cosine'
%     The type of similarity measure to be computed.
%
%   FMode:: ''
%     The reweighting function f to use for computing reweightedSim(w1, w2).
%
%   Beta:: []
%     The impact factors to use for computing reweightedSim(w1, w2).
%      
%   CorrelationType:: 'Spearman' 
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

options.channels = {'text', 'image'};
options.similarityMeasure = 'cosine';
options.fMode = '';
options.beta = [];
options.correlationType = 'Spearman';

options = vl_argparse(options, varargin);

% check if fMode and beta have been passed as arguments 
if isempty(options.fMode) || isempty(options.beta)
    if isempty(options.fMode)
        error('testModel:arguments_error','A valid fMode must be specified')
    end
    if isempty(options.beta)
        error('testModel:arguments_error','A valid beta must be specified')
    end
end


% -------------------------------------------------------------------
%                                                      Test the model
% -------------------------------------------------------------------

% cycle over the two channels text and image
for j = 1:numel(options.channels)
    scoreIndex = 1;
    for i = 1:numel(test.data{1})
        % Note that a dataset for computing semantic similarity is
        % constituted of a list of concept pairs together with their
        % associated gold scores. That's what test.data contains.
        % See [1] for a traiditional semantic similarity dataset.
        concept1 = test.data{1}{i}; % transform to test.data
        concept2 = test.data{2}{i};
        goldScore = test.data{3}(i);
        
        % check if both concepts have a reweighting weight
        if weights.isKey(concept1) == 1 && weights.isKey(concept2) == 1
            
            weight1 = (1 - weights(concept1))/options.beta;
            weight2 = (1 - weights(concept2))/options.beta;
            
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
                [weight1 weight2], options.fMode);
            
            if pairScore ~= -1
                % populate the model and the test scores
                testScores(scoreIndex,1) = goldScore;
                modelScores(scoreIndex,j) = pairScore;
                % store the pairs for which a similarity score was computed
                scoredPairs{scoreIndex} = {concept1 concept2};
                scoreIndex = scoreIndex+1;
            end
        end
        
    end
end

combinedModelScores = 0;
for c = 1:numel(options.channels)
    % Combine the similarity scores provided by the two channels
    % independently. This is typycally called late fusion.
    combinedModelScores = combinedModelScores + modelScores(:,c);
end

% compute the correlation of the combined model scores
testCorr = corr(testScores, combinedModelScores, 'type', options.correlationType);
% fit testedData with pairs and scores used to compute the correlation
testedData{1} = scoredPairs;
testedData{2} = combinedModelScores;