%% benchmarks.helpers.SimilarityExtractor class
%
% *Package:* benchmarks.helpers
%
% <html>
% <span style="color:#666">Compute similarity between concepts</span>
% </html>
%
%% Description
%
% |benchmarks.helpers.SimilarityExtractor| constructs an object to compute 
% the similarity scores between concepts.
%
%
%% Construction
%
% |similarityExtractor = benchmarks.helpers.SimilarityExtractor('OptionName', optionValue,...)|
%
%
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
%
% |Similarity| The similarity measure to use for comparing the target 
% concept pairs. The possible similarities are |'cosine'| (default), |'seuclidean'|,
% |'cityblock'|, |'minkowski'|, |'chebychev'|, |'mahalanobis'|, |'euclidean'|, 
% |'correlation'|, |'spearman'|, |'hamming'|and |'jaccard'|.
% 
%% Properties
%
% |Options| Contain the options of the class.
%
% |Similarities| Contain the list of all possible similarities.
%
%% Methods
%
% |scores = computeSimilarity(obj, conceptSpace, conceptPairs)| Compute the similarity scores for the target concepts.