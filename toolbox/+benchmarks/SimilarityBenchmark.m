classdef SimilarityBenchmark < benchmarks.GenericBenchmark
    % SimilarityBenchmark Compute similarity benchmark
    %   SimilarityBenchmark('OptionName',optionValue,...) constructs
    %   an object to compute the similarity benchmark for a set of concepts
    %
    %   The benchmark behaviour can be adjusted by modifying the following options:
    %
    %   BenchmarkName:: 'wordsim'
    %     The name of the similarity benchmark to use.
    %
    %     'wordsim'
    %
    %     'menFull'
    %
    %     'menDev'
    %
    %     'menTest'
    %
    %     'pascal'
    %
    %
    %   Correlation:: 'spearman'
    %      The type of correlation measure to use to compare the human and
    %      the model data.
    %
    %     'kendall'
    %
    %     'pearson'
    %
    %     'spearman'
    %
    %
    % Authors: A1
    
    % AUTORIGHTS
    %
    % This file is part of the VSEM library and is made available under
    % the terms of the BSD license (see the COPYING file).
    
    properties (SetAccess=protected, GetAccess=public)
        % These are the options for changing the behaviour of this class. A
        % default initialization of the options is offered.
        options = struct(...
            'benchmarkName', 'wordsim',...
            'correlation', 'spearman');
        % The benchmark in usage by the class.
        benchmark; 
    end
    
    properties (Constant)
        % This is the list of values that can be used to change the
        % configuration options of this class.
        Correlations = {'kendall', 'pearson', 'spearman'};
        BenchmarkNames = {'wordsim', 'menFull', 'menDev', 'menTest', 'pascal'};
    end
    
    properties (Constant, Hidden)
        WordsimPath = fullfile(vsemRoot,'data/benchmarks/wordsim.csv');
        MenFullPath = fullfile(vsemRoot,'data/benchmarks/menFull.csv');
        MenDevPath = fullfile(vsemRoot,'data/benchmarks/menDev.csv');
        MenTestPath = fullfile(vsemRoot,'data/benchmarks/menTest.csv');
        PascalPath = fullfile(vsemRoot,'data/benchmarks/pascal.csv');
    end
    
    methods
        function obj = SimilarityBenchmark(varargin)
            % The constructor of the class. If no arguments are given, a
            % default configuration is instantiated.
            import benchmarks.*;
            
            if numel(varargin) > 0
                obj.options = vl_argparse(obj.options,varargin);
            end
            obj.options.benchmarkName = obj.options.benchmarkName;
            if ~ismember(obj.options.benchmarkName, obj.BenchmarkNames)
                error('Invalid benchmark name %s.',obj.options.benchmarkName);
            end
            
            % Build all the data necessary for benchmarking
            obj.benchmark = obj.buildBenchmark();
            
            obj.options.correlation = lower(obj.options.correlation);
            if ~ismember(obj.options.correlation, obj.Correlations)
                error('Invalid correlation %s.',obj.options.correlation);
            end
        end
        
        function [RHO, PVAL] = computeBenchmark(obj, conceptSpace, similarityExtractor)
            % computeBenchmark Compute similarity becnhmark
            %   [RHO, PVAL] = obj.computeBenchmark(obj, concepts,
            %   similarityExtractor) computes the chosen similarity benchmark
            %   for the given concepts.
            [benchmarkPairs, benchmarkScores] = filterBenchmark(obj, conceptSpace);

            if numel(benchmarkPairs) > 0
                modelScores = similarityExtractor.computeSimilarity(conceptSpace, ...
                    benchmarkPairs);
                [RHO, PVAL] = corr(benchmarkScores, modelScores, 'type', ...
                    obj.options.correlation, 'rows', 'complete');
            else
               fprintf(1, 'No overlap between benchmark and concept space.\n');
               RHO = NaN;
               PVAL = NaN; 
            end
        end
    end
    
    methods (Access = protected)
        function benchmark = buildBenchmark(obj)
            % Prepares the chosen benchmark for computation.
            switch obj.options.benchmarkName
                case 'wordsim'
                    benchmark = obj.readBenchmark(obj.WordsimPath);
                case 'menFull'
                    benchmark = obj.readBenchmark(obj.MenFullPath);
                case 'menDev'
                    benchmark = obj.readBenchmark(obj.MenDevPath);
                case 'menTest'
                    benchmark = obj.readBenchmark(obj.MenTestPath);
                case 'pascal'
                    benchmark = obj.readBenchmark(obj.PascalPath);
            end
        end
        
        function [benchmarkPairs, benchmarkScores]= filterBenchmark(obj, conceptSpace)
            % Retains only the benchmark pairs and scores for which there
            % is a concept representation.
            benchmarkPairs = {};
            benchmarkScores = [];
            idx = 1;
            for i = 1:numel(obj.benchmark{1})
                if conceptSpace.isConcept(obj.benchmark{1}{i}) == 1 && conceptSpace.isConcept(obj.benchmark{2}{i}) == 1
                    benchmarkPairs{idx}{1} = obj.benchmark{1}{i};
                    benchmarkPairs{idx}{2} = obj.benchmark{2}{i};
                    benchmarkScores(idx,1) = obj.benchmark{3}(i);
                    idx = idx + 1;
                end
            end
        end
    end
    
    methods (Static, Access = protected)
        function benchmark = readBenchmark(benchmarkPath)
            % Read a semantic benchmark from file.
            [concepts1, concepts2, goldScores] = textread(benchmarkPath, '%s%s%f','delimiter', ';');
            benchmark{1} = concepts1;
            benchmark{2} = concepts2;
            benchmark{3} = goldScores;
        end
    end
    
end
