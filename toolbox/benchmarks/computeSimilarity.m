function scores = computeSimilarity(conceptSpace, conceptPairs, varargin)
% computeSimilarity Compute the similarity scores
%   scores = computeSimilarity(conceptSpace, conceptPairs, varargin)
%   computes the similarity scores for the target concepts.
%

% Author: Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).
similarities = {'euclidean', 'seuclidean', 'cityblock'...
    'minkowski', 'chebychev', 'mahalanobis', 'cosine'...
    'correlation', 'spearman', 'hamming', 'jaccard'};
opts.similarity = 'cosine';
opts = vl_argparse(opts, varargin);

if ~ismember(opts.similarity, similarities)
    error('Invalid similarity %s.', similarity);
end

scores = 0;
for i = 1:numel(conceptPairs)
    concept1 = conceptPairs{i}{1};
    concept2 = conceptPairs{i}{2};
    if isConcept(conceptSpace, concept1) == 1 && isConcept(conceptSpace, concept2) == 1
        vector1 = getConceptMatrix(conceptSpace, concept1)';
        vector2 = getConceptMatrix(conceptSpace, concept2)';
        scores(i,1) = 1 - pdist2(vector1, vector2, opts.similarity);
    else
        scores(i,1) = -1;
    end
end