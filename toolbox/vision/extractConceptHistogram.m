function [histogram, objectList] = extractConceptHistogram(encoder, imagePath, annotation)
% GETDENSESIFT   Extract dense SIFT features
%   FEATURES = GETDENSESIFT(IM) extract dense SIFT features from
%   image IM.

% Author: Andrea Vedaldi

% Copyright (C) 2013 Andrea Vedaldi
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

    opts.localization = 'global';

    

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
            histogram{k} = encodeImage(encoder, imagePath, 'object', boundingBox);
        end
        
        % standardizing histogram
        histogram = cat(2, histogram{:});
end % switch
end % extractConceptHistogram