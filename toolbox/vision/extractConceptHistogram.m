function [histogram, objectList] = extractConceptHistogram(encoder, imagePath, annotation, varargin)



opts.localization = [];
opts = vl_argparse(opts, varargin) ;

if isempty(opts.localization)
    opts.localization = 'global';
end

switch lower(opts.localization)
    case 'global'
        
        % extracting unique objects for the image
        objectList = cellfun(@(x)x, annotation(1,:), 'UniformOutput', false);
        objectList = unique(objectList);
        
        % computing histogram
        histogram = encodeImage(encoder, imagePath);
        
        
    case 'surrounding'        
        % checking for input errors
        assert(size(annotation, 1) == 2,'Localization data unavailable, check annotation or select ''global'' localization.')
        
        % extracting object list
        objectList = cellfun(@(x)x, annotation(1,:), 'UniformOutput', false)';
        
        % initializing histogram representation
        histogram = cell(1, size(annotation, 2));
        
        % iterating over the whole set of concepts
        for k = 1:size(annotation, 2)
            
            % extracting bounding box
            boundingBox = annotation{2,k};
            
            % computing histogram for the kth object
            histogram{k} = encodeImage(encoder, imagePath, 'surrounding', boundingBox);
        end
        
        % standardizing histogram
        histogram = cat(2, histogram{:});
        
    case 'object'

        % checking for input errors
        assert(size(annotation, 1) == 2,'Localization data unavailable, check annotation or select ''global'' localization.')
        
        % extracting object list
        objectList = cellfun(@(x)x, annotation(1,:), 'UniformOutput', false)';
        
        % initializing histogram representation
        histogram = cell(1, size(annotation, 2));
        
        % iterating over the whole set of concepts
        for k = 1:size(annotation, 2)
            
            % extracting bounding box
            boundingBox = annotation{2,k};
            
            % computing histogram for the kth object
            %histogram = encodeImage2(encoder, imagePath);
            histogram{k} = encodeImage(encoder, imagePath, 'object', boundingBox);
            
        end
        
        % standardizing histogram
        histogram = cat(2, histogram{:});
end % switch
end % extractConceptHistogram