function [testCorr testedData] = testModel(MSS, test, weights, varargin)
% TESTMODEL  Test a multimodal semantic space
%   [TESTCORR, TESTEDDATA] = TestMODEL(MSS, TEST, WEIGHTS, PARAMS) test the
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
%   f = mean,min,max
%   weights = the weight for the given concept (e.g., imageability score)
%   beta = models the impact of rs in the reweighting
%
%
%   MSS:: [semantics.representation.MultimodalSemanticSpace]
%     This is the multimodal semantic space to be tested.
%
%   test:: 
%     The testing data.
%
%   weights::
%     The weights for computing reweightedSim(w1, w2).
%
%   channels:: {'text', 'image'}
%     The channels of the multimodal models.
%
%   similarityMeasure:: 'cosine'
%     The type of similarity measure to be computed.
%
%   fMode:: ''
%     The reweighting function f to use for computing reweightedSim(w1, w2).
%
%   beta:: []
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

options.channels = {'text', 'image'};
options.similarityMeasure = 'cosine';
options.fmode = '';
options.beta = [];
options.correlationType = 'Spearman';

options = vl_argparse(options, varargin);

% check if fmode and beta have been passed as arguments 
if length(options.fmode) == 0 || isempty(options.beta)
    if length(options.fmode) == 0
        error('testModel:arguments_error','A valid fmode must be specified')
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
                options.fmode,...
                [weight1 weight2]);
            
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