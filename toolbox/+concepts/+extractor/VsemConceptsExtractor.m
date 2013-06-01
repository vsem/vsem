classdef VsemConceptsExtractor
% VsemConceptsExtractor concept extractor
%   VsemConceptsExtractor('optionName', 'optionValue') serves as a handle
%   for the extractConcepts method, which is responsible for the
%   construction of ConceptSpace from a certain dataset of annotated images
%   and with a certain histogram extractor.
%
%   Options:
%
%   'subbin_norm_type':: 'none'
%     Normalization for sub bins of a concept.
%
%   'norm_type':: 'none'
%     Normalization for the complete concept.
%
%   'post_norm_type':: 'none'
%     Normalization for the complete concept after kernel map application.
%   
%   Possible normalizations are 'l1' or 'l2'.
%
%   'kermap':: 'none'
%     Applies kernel map to a concept. Either 'homker' or 'hellinger'.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

    
    properties
        extractorConfiguration = struct(...
            'subbin_norm_type', 'none',...
            'norm_type', 'none',...
            'post_norm_type', 'none',...
            'kermap', 'none')
    end
    
    properties (Constant, Hidden)
        normalizationType = {'l1', 'l2', 'none'};
        kernelMap = {'homker', 'hellinger', 'none'};
    end
    
    methods
        function obj = VsemConceptsExtractor(varargin)
            
            % parsing input for options
            obj.extractorConfiguration = vl_argparse(obj.extractorConfiguration,varargin);
            
            % checking input validity
            assert(all(ismember({obj.extractorConfiguration.subbin_norm_type,...
                obj.extractorConfiguration.norm_type,...
                obj.extractorConfiguration.post_norm_type},...
                obj.normalizationType)),'The normalization type must be ''l1'', ''l2'' or ''none''.');
            
            assert(ismember(obj.extractorConfiguration.kermap, obj.kernelMap), 'Kernel map must be ''homker'', ''hellinger'' or ''none''.');
        end
        
        function conceptSpace = extractConcepts(obj, histogramExtractor, ...
                imagePaths, annotations, conceptList)
        % extractConcepts concept extractor main utility
        %   extractConcepts(obj, dataset, histogramExtractor, 'optionName',
        %   'optionValue') builds a concept space from the 'dataset'
        %   using 'histogramExtractor' to obtain bovw histograms
        %   for every image in the dataset. In returns the concept space
        %   itself.
        %
        %   Options:
        %
        %   extractConcepts uses the dataset getAnnotatedImages method,
        %   which is the only recipient of any additional option. See help
        %   for getAnnotatedImages method to review available options.

            % Check if we have the same number of images and corresponding tags
            assert(length(imagePaths) == length(annotations), ...
                'Number of images does not match the number of annotations');
           
            % initializing concept matrix with pooling output dimension
            conceptMatrix = zeros(histogramExtractor.pooler.get_output_dim, ...
                length(conceptList));
            
            % initializing concept space
            conceptSpace = concepts.space.ConceptSpace(conceptList, conceptMatrix);
            
            % settings for progress bar graphics and variables
            text = 'Extracting concepts: ';
            barColor = [0.76 0.24 0.45];
            waitBar = helpers.graphics.WaitBar(length(imagePaths), text, barColor);
            
            % extracting concepts over the whole selected set of images
            for i = 1:size(imagePaths, 1)
                
                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    break
                end
                
                % updating waitbar
                waitBar.update(i);
                try 
                    % extracting histogram and object list for the ith image
                    [histogram, objectList] = histogramExtractor.extractConceptHistogram(...
                        imagePaths{i}, annotations{i});
                    
                    % updating concept space with the previously extracted data
                    conceptSpace = conceptSpace.update(histogram, objectList);
                catch ME
                    switch ME.identifier
                        case 'VSEM:FeatExt'
                            fprintf(1, '%s\n', ME.message);
                        otherwise
                            fprintf(1, 'Error reading file: %s\n', imagePaths{i});
                    end
                end % try-catch block
            end % image iteration
            
            % checking for sub bin normalization
            if ~strcmpi(obj.extractorConfiguration.subbin_norm_type, 'none')
                conceptSpace = conceptSpace.normalize('bins', obj.extractorConfiguration.subbin_norm_type);
            end
            
            % checking for complete normalization
            if ~strcmpi(obj.extractorConfiguration.norm_type, 'none')
                conceptSpace = conceptSpace.normalize('whole', obj.extractorConfiguration.norm_type);
            end
            
            % checking for kernel map application
            if ~strcmpi(obj.extractorConfiguration.kermap, 'none')
                conceptSpace = conceptSpace.applyKernelMap(obj.extractorConfiguration.kermap);
            end
            
            % checking for post-kernel map application normalization
            if ~strcmpi(obj.extractorConfiguration.post_norm_type, 'none')
                conceptSpace = conceptSpace.normalize('whole', obj.extractorConfiguration.post_norm_type);
            end
        end
    end
end
