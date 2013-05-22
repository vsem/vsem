%% benchmarks.SimilarityBenchmark class
%
% *Package:* benchmarks
%
% <html>
% <span style="color:#666">Compute similarity benchmark</span>
% </html>
%
%% Description
%
% |benchmarks.SimilarityBenchmark| constructs an object to compute 
% the similarity benchmark for a set of concepts.
%
%
%% Construction
%
% |similarityExtractor = benchmarks.SimilarityBenchmark('OptionName', optionValue,...)|
%
%
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
%
% |BenchmarkName| The name of the similarity benchmark to use. The possible
% benchmarks are |'wordsim'|,|'menFull'|,|'menDev'|,|'menTest'| and |'pascal'|.
%
% |Correlation| The type of correlation measure to use to compare the human 
% and the model data. The possible correlations are |'kendall'|, |'pearson'| and |'spearman'|.
% 
%% Properties
%
% |Options| Contain the options of the class.
%
% |Benchmark| The benchmark in usage by the class.
%
% |Correlations| The list of correlations at disposal for the class.
%
% |BenchmarkNames| The name of the benchmarks at disposal for this class.
%
%% Methods
%
% |[RHO, PVAL] = computeBenchmark(obj, conceptSpace, similarityExtractor)| Compute
% the chosen similarity benchmark for the given concepts.