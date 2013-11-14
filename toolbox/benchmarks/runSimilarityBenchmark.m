function [RHO, PVAL, coverage] = runSimilarityBenchmark(conceptSpace, benchmarkName, varargin)
% computeBenchmark Compute similarity becnhmark
%   [RHO, PVAL] = obj.computeBenchmark(obj, concepts,
%   similarityExtractor) computes the chosen similarity benchmark
%   for the given concepts.
%

% Author: Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

data.wordsimPath = fullfile(vsem_root,'data/benchmarks/wordsim.csv');
data.menFullPath = fullfile(vsem_root,'data/benchmarks/menFull.csv');
data.menDevPath = fullfile(vsem_root,'data/benchmarks/menDev.csv');
data.menTestPath = fullfile(vsem_root,'data/benchmarks/menTest.csv');
data.pascalPath = fullfile(vsem_root,'data/benchmarks/pascal.csv');

opts.similarity = 'cosine';
opts.correlation = 'spearman';
opts = vl_argparse(opts, varargin);


% Prepares the chosen benchmark for computation.
switch benchmarkName
    case 'wordsim'
        benchmark = readBenchmark(data.wordsimPath);
    case 'menFull'
        benchmark = readBenchmark(data.menFullPath);
    case 'menDev'
        benchmark = readBenchmark(data.menDevPath);
    case 'menTest'
        benchmark = readBenchmark(data.menTestPath);
    case 'pascal'
        benchmark = readBenchmark(data.pascalPath);
end


[benchmarkPairs, benchmarkScores, coverage] = filterBenchmark(benchmark, conceptSpace);


if numel(benchmarkPairs) > 0
    modelScores = computeSimilarity(conceptSpace, ...
                                    benchmarkPairs, ...
                                    'similarity', opts.similarity);
                                
    [RHO, PVAL] = corr(benchmarkScores, modelScores, ... 
                       'type', opts.correlation, ...
                       'rows', 'complete');
else
    fprintf(1, 'No overlap between benchmark and concept space.\n');
    RHO = NaN;
    PVAL = NaN;
end
end

% -------------------------------------------------------------------------
function benchmark = readBenchmark(benchmarkPath)
% -------------------------------------------------------------------------
% Read a semantic benchmark from file.
[concepts1, concepts2, goldScores] = textread(benchmarkPath, '%s%s%f','delimiter', ';');
benchmark{1} = concepts1;
benchmark{2} = concepts2;
benchmark{3} = goldScores;
end

% -------------------------------------------------------------------------
function [benchmarkPairs, benchmarkScores, coverage]= filterBenchmark(benchmark, conceptSpace)
% -------------------------------------------------------------------------
% Retains only the benchmark pairs and scores for which there
% is a concept representation.
benchmarkPairs = {};
benchmarkScores = [];
idx = 1;
for i = 1:numel(benchmark{1})
    if isConcept(conceptSpace, benchmark{1}{i}) == 1 && isConcept(conceptSpace, benchmark{2}{i}) == 1
        benchmarkPairs{idx}{1} = benchmark{1}{i};
        benchmarkPairs{idx}{2} = benchmark{2}{i};
        benchmarkScores(idx,1) = benchmark{3}(i);
        idx = idx + 1;
    end
end
coverage=[idx,length(benchmark{1})];

end