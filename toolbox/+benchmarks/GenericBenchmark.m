classdef GenericBenchmark
    % GenericBenchmark The base class of a benchmark
    %   Defines the abstract methods that have to be implemented from its
    %   subclasses.
    %
    % Authors: A1
    
    % AUTORIGHTS
    %
    % This file is part of the VSEM library and is made available under
    % the terms of the BSD license (see the COPYING file).
        
    methods (Abstract)
        % The constructor of the class. 
        obj = SimilarityBenchmark(varargin)
        
        % Compute becnhmark
        score = computeBenchmark(obj, concepts, varargin)
	
	end
	
	methods (Abstract, Access = protected)
        % Build benchmark
        benchmark = buildBenchmark(obj)
    end
    
end