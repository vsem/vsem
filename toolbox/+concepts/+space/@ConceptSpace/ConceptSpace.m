classdef ConceptSpace
% ConceptSpace visual concept vectors handling facility
%   ConceptSpace(conceptList, conceptMatrix, 'optionName', 'optionValue')
%   builds the concept handling class for the concepts in the 'conceptList'
%   cell array and with initial concept matrix 'conceptMatrix', which is
%   responsible for updating (aggregation), normalizing, applying a kernel
%   map to, reweighting and reducing the visual concept vectors. Moreover,
%   it allows concept list and matrix displaying methods and the isConcept
%   method, which provides a way to check if a concept is in the concept
%   space.
%
%   The following options at disposal:
%
%   'aggregatorFunction':: @concepts.space.aggregator.sum
%     Aggregator function handle.
%
%   'reweightingFunction':: @concepts.space.transformations.reweighting.lmiReweight
%     Reweighting function handle.
%
%   'reducingFunction':: @concepts.space.transformations.reducing.SVDreduce
%     Reducing function handle.
%
%   'readFromFile'
%     Reads the concept space from a file and requires a cell array with
%     the file path and the number of features for that file, in this
%     order. Set 'conceptList' and 'outputDimension' to 'none'.
%
%
%   Help is available for every method of the class (e.g. help
%   concepts.space.ConceptSpace.update)
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).
    
    
    properties
        conceptIndex
        conceptMatrix
        options = struct(...
            'aggregatorFunction', @concepts.space.aggregator.sum,...
            'reweightingFunction', @concepts.space.transformations.reweighting.lmiReweight,...
            'reducingFunction', @concepts.space.transformations.reducing.SVDreduce);
    end
    
    properties (Access = protected, Hidden)
        aggregatorFunction
        reweightingFunction
        reducingFunction
    end
    
    properties (Constant, Hidden)
        normalizationType = {'l1', 'l2'};
        normalizationSize = {'whole', 'bins'}
        kernels = {'homker', 'hellinger'};
    end
    
    methods
        function obj = ConceptSpace(conceptList, conceptMatrix, varargin)
            
            % parsing aggregation function, storing it as protected property
            [obj.options, varargin] = vl_argparse(obj.options, varargin);
            obj.aggregatorFunction = obj.options.aggregatorFunction;
            
            % checking for 'readFromFile' option
            if ~isempty(varargin)
                if strcmpi(varargin{1}, 'readfromfile')
                    
                    % extracting file name and features number from input
                    fileName = varargin{2}{1};
                    numberOfFeatures = varargin{2}{2};
                    
                    % reading and storing index and matrix for the concept space
                    [obj.conceptIndex, obj.conceptMatrix] = concepts.space.helpers.readConceptSpace(fileName, numberOfFeatures);
                    
                else
                    error('Input is not correct. See help concepts.space.ConceptSpace as reference.')
                end
            else
                % inizializing reference index for concepts inside the matrix
                obj.conceptIndex = containers.Map(conceptList, 1:length(conceptList));
                
                % initializing matrix for concept representation
                obj.conceptMatrix = conceptMatrix;
            end  
        end
        
        obj = update(obj, histogram, objectList)
        
        obj = normalize(obj, normSize, normType)
        
        obj = applyKernelMap(obj, kernelMap)
        
        function obj = reweight(obj, varargin)
        % reweight reweighting utility for the concept space
        %   reweight(obj, 'optionName', 'optionValue') reweights the
        %   concept matrix. A default reweighting function is provided and
        %   can be reviewed in the 'options' property of the object.
        %   Reweighted matrix can be reassigned to the original object or
        %   to a new one to preserve original data.
        %
        %   Options:
        %
        %   'reweightingFunction'
        %     Handle to the reweighting function (e.g.
        %     @concepts.space.transformations.reweighting.lmiReweight)
        
        
            % parsing input for new reweighting function and assigning it
            % to the protected property with the same name
            obj.options = vl_argparse(obj.options, varargin);
            obj.reweightingFunction = obj.options.reweightingFunction;
            
            % computing rewighting
            obj.conceptMatrix = obj.reweightingFunction(obj.conceptMatrix);
        end

        function obj = reduce(obj, dimensions, varargin)
        % reduce reducing utility for the concept space
        %   reduce(obj, dimensions, 'optionName', 'optionValue') reduces
        %   the concept matrix to 'dimensions' dimension. A default
        %   reducing function is provided and can be reviewed in the
        %   'options' property of the object. Reduced matrix can be
        %   reassigned to the original object or to a new one to preserve
        %   original data.
        %
        %   Options:
        %
        %   'reducingFunction'
        %     Handle to the reducing function (e.g.
        %     @concepts.space.transformations.reducing.SVDreduce)
        
            
            
            % parsing input for new reducing function and assigning it to
            % the protected property with the same name
            obj.options = vl_argparse(obj.options, varargin);
            obj.reducingFunction = obj.options.reducingFunction;
            
            % computing reduction
            obj.conceptMatrix = obj.reducingFunction(obj.conceptMatrix', dimensions)';
        end
        
        function idxs = isConcept(obj, conceptList)
        % isConcept concept space handling utility
        %   isConcept(obj, conceptList) determines which concepts in the
        %   cell array 'conceptList' are in the concept space. Returns a
        %   logical array.
        
        
            idxs = obj.conceptIndex.isKey(conceptList);
        end
        
        function conceptList = getConceptList(obj)
        % getConceptList concept list for the concept space
        %   getConceptList(obj) returns the 1xN cell array of concepts in
        %   the concepts space.
            
            
            conceptList = obj.conceptIndex.keys;
        end
        
        function conceptMatrix = getConceptMatrix(obj, varargin)
        % conceptMatrix concept matrix for the concept space
        %   getConceptMatrix(obj, 'optionName', 'optionValue') returns, by
        %   default, the complete visual concept matrix for concept space.
        %   Alternatively, it returns the matrix for the concept or cell
        %   array of concepts it was requested for.
        
        
            if nargin == 1
                % returning the complete matrix by default
                conceptMatrix = obj.conceptMatrix;
            elseif nargin == 2
                % checking for errors in the input list
                assert(all(obj.isConcept(varargin{:})), 'Some of the selected concepts are not in the concept space.');
                
                % standardizing input for one single concept list
                if ischar(varargin{:}), varargin = {varargin}; end
                
                % extracting indexes and matrix for the selected concepts
                idxs = obj.conceptIndex.values(varargin{:});
                idxs = cat(1,idxs{:});
                
                conceptMatrix = obj.conceptMatrix(:,idxs);
            else
                % checking for invalid input
                error('Invalid input argument. Select a single concept or a cell array of concepts. Default: complete matrix.')
            end
        end
    end
end
