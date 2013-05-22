classdef SimilarityExtractor
    % SimilarityExtractor Compute similarity between concepts
    %   SimilarityExtractor('OptionName',optionValue,...)
    %   constructs an object to compute the similarity scores between
    %   concepts.
    %
    %   The extraction behaviour can be adjusted by modifying the following options:
    %
    %   Similarity:: 'cosine'
    %     The similarity measure to use for comparing the target concept
    %     pairs.
    %
    %     'cosine'
    %
    %     'seuclidean'
    %
    %     'cityblock'
    %
    %     'minkowski'
    %
    %     'chebychev'
    %
    %     'mahalanobis'
    %
    %     'euclidean'
    %
    %     'correlation'
    %
    %     'spearman'
    %
    %     'hamming'
    %
    %     'jaccard'
    %
    %
    %
    % Authors: A1
    
    % AUTORIGHTS
    %
    % This file is part of the VSEM library and is made available under
    % the terms of the BSD license (see the COPYING file).
    
    
    properties
        % These are the options for changing the behaviour of this class. A
        % default initialization of the options is offered.
        options = struct(...
            'verbose', true,...
            'similarity', 'cosine');
    end
    
    properties(Constant)
        % This is the list of values that can be used to change the
        % configuration options of this class.
        Similarities = {'euclidean', 'seuclidean', 'cityblock'...
            'minkowski', 'chebychev', 'mahalanobis', 'cosine'...
            'correlation', 'spearman', 'hamming', 'jaccard'};
    end
    
    methods
        function obj = SimilarityExtractor(varargin)
            % The constructor of the class. If no arguments are given, a
            % default configuration is instantiated.
            import benchmarks.*;
            if numel(varargin) > 0
                obj.options = vl_argparse(obj.options,varargin);
            end
            if ~islogical(obj.options.verbose)
                error('Invalid verbose state %s.',obj.options.verbose);
            end
            obj.options.similarity = lower(obj.options.similarity);
            if ~ismember(obj.options.similarity, obj.Similarities)
                error('Invalid similarity %s.',obj.options.similarity);
            end
        end
        
        function scores = computeSimilarity(obj, conceptSpace, conceptPairs)
            % computeSimilarity Compute the similarity scores
            %   scores = computeSimilarity(obj, concepts, conceptPairs)
            %   computes the similarity scores for the target concepts.
            scores = 0;
            for i = 1:numel(conceptPairs)
                concept1 = conceptPairs{i}{1};
                concept2 = conceptPairs{i}{2};
                if conceptSpace.isConcept(concept1) == 1 && conceptSpace.isConcept(concept2) == 1
                    vector1 = conceptSpace.getConceptMatrix(concept1)';
                    vector2 = conceptSpace.getConceptMatrix(concept2)';
                    scores(i,1) = 1 - pdist2(vector1, vector2, obj.options.similarity);
                else
                    scores(i,1) = -1;
                end
            end
        end
    end
    
end