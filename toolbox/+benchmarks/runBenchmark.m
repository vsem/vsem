function [score, pValue] = runBenchmark(conceptSpace, benchmarkName)
    simext = benchmarks.helpers.SimilarityExtractor();
    benchmark = benchmarks.SimilarityBenchmark('benchmarkName', benchmarkName);

    [score, pValue] = benchmark.computeBenchmark(conceptSpace, simext);
end
