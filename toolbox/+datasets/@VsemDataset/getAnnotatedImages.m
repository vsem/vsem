function annotatedImages = getAnnotatedImages(obj, varargin)
% getAnnotatedImages Nx1 cell array of image paths and related
% annotation.
%   getImagesPaths('optionName', 'optionValue') returns 'imageData', a Nx2
%   cell array of image paths and their annotation, according to the
%   requested subset in the 'optionName' argument, along with 
%   'conceptList', a Nx1 cell array with the list of concepts the images in
%   imageData have a record of as objects/tags. No input returns these two
%   lists for the complete dataset.
%
%   Options list:
%
%   'fileNames'
%     Followed by a cell array of file name strings extracts a list for
%     that subset of images only.
%
%   'conceptNames'
%     Followed by a cell array of concept names extracts a list for that 
%     subset of concepts only.
%
%   'imageLimit'
%     Together with a number, it selects an as big subset of dataset
%     entries.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


if nargin > 1
    
    % checking for correct input
    if nargin > 3
        error('Specify what kind of list you want to input (either ''fileNames'' or ''conceptNames'' - not both) and provide a 1xN cell array with the list itself; alternatively, input ''imageLimit'' and the number of random images requested.');
    end
    
    % assigning input data
    subsetType = varargin{1};
    subsetData = varargin{2};
    
    if strcmpi(subsetType,'fileNames')
        
        % making a first paths list to check for their existence
        imagesPaths = {obj.imageData.filePath};
        [~, imageFilenames, ~] = cellfun(@fileparts, imagesPaths, ...
            'UniformOutput', false);
        
        [~, subsetData, ~] = cellfun(@(x)(fileparts(x)), subsetData, ...
            'UniformOutput',false);

        pathIdxs = find(ismember(imageFilenames, subsetData));

        requestedPaths = imagesPaths(pathIdxs);
        
        % checking for existence
        assert(all(cellfun(@(x)(exist(x,'file')), requestedPaths)), ...
            'Some of the requested images are not in the images folder. Check for spelling or for file location.');
        
        % requested image paths and annotation
        annotatedImages.imageData = requestedPaths;
        annotatedImages.imageData(:,2) = {obj.imageData(pathIdxs).annotation}';
        
        % requested images concept list
        annotation = cat(2, annotatedImages.imageData{:,2});
        annotatedImages.conceptList = unique(annotation(1,:))';
        
    elseif strcmpi(subsetType,'conceptNames')
        
        % concept list is in the input
        annotatedImages.conceptList = subsetData;
        
        % checking whether all the concepts are in the dataset's concept list
        assert(all(ismember(annotatedImages.conceptList,obj.conceptList)),'Some selected concepts are not in the list of possible concepts, check for possible objects (dataset.conceptList) or for spelling.');
        
        % allocating
        annotatedImages.imageData = {};
        i = 1;
        
        % iterating on the whole dataset
        for j = 1:length(obj.imageData)
            
            % extracting object list for the jth image
            objectNames = obj.imageData(j).annotation(1,:);
            
            % if none of the objects in the objectNames list is in the list
            % of requested concepts (conceptNames), skip to the next image
            if ~any(ismember(objectNames,annotatedImages.conceptList))
                continue
            end
            
            % storing path for the jth image in the ith position (where i keeps track of wanted images)
            annotatedImages.imageData{i,1} = obj.imageData(j).filePath;
            
            % initializing the number of wanted objects
            k = 1;
            
            % iterating on the whole set of concepts
            for l=1:length(objectNames)
                
                % extracting lth object name
                objectName = objectNames(l);
                
                % skipping unwanted objects
                if ~any(ismember(objectName,annotatedImages.conceptList))
                    continue
                end
                
                % adding annotation data for the lth and updating wanted objects list
                annotatedImages.imageData{i,2}{k} = obj.imageData(j).annotation(:,l);
                k = k + 1;
            end
            
            % uniforming output and updating wanted images list
            annotatedImages.imageData{i,2} = cat(2, annotatedImages.imageData{i,2}{:});
            i = i + 1;
        end
        
    elseif strcmpi(subsetType,'imageLimit')
        
        if subsetData > 0
            
            % initializing dataset indexes to be randomized
            idxs = 1:length(obj.imageData);
            
            % misuse warning
            if subsetData > length(idxs)
                warning('Image limit exceeds dataset dimension: no discount will be applied.');
            end

            % randomizing indexes and picking the requested number
            idxs = vl_colsubset(idxs, subsetData);
            
            % extracting paths and annotation for the subset of images
            imagesPaths = {obj.imageData(idxs).filePath}';
            annotation = {obj.imageData(idxs).annotation}';
            
            % standardizing output and assigning
            annotatedImages.imageData = cat(2, imagesPaths, annotation);
            annotation = cat(2, annotation{:});
            
            annotatedImages.conceptList = unique(annotation(1,:))';
            
        else
            
            % misuse warning
            warning('Image limit is not a positive integer: no discount will be applied.');
            
            % proceeding with the extraction of annotated images from the whole dataset
            imagesPaths = {obj.imageData.filePath}';
            annotation = {obj.imageData.annotation}';
            
            annotatedImages.imageData = cat(2, imagesPaths, annotation);
            
            annotatedImages.conceptList = obj.conceptList;
        end
        
    else
        % checking for correct input
        error('Make sure you choose either fileNames or conceptNames option, followed by a 1xN cell array where N is the number of elements of the required list. Otherwise input ''imageLimit'' and the number of random images requested.')
    end
    
else
    
    % extracting image paths and annotation from the whole dataset
    imagesPaths = {obj.imageData.filePath}';
    annotation = {obj.imageData.annotation}';
    
    % assigning to output
    annotatedImages.imageData = cat(2, imagesPaths, annotation);
    annotatedImages.conceptList = obj.conceptList;
end
end
