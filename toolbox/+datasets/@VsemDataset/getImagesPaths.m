function imagesPaths = getImagesPaths(obj, varargin)
% getImagesPaths Nx1 cell array of complete image paths
%   getImagesPaths('optionName', 'optionValue') returns a Nx1 cell array
%   which is a list of paths for the subset of images the list was 
%   requested for. No input returns the list for the complete dataset.
%
%   Options list:
%
%   'fileNames'
%     Followed by a cell array of file name strings extracts a list for
%     that subset of images only.
%
%   'conceptNames'
%     Followed by a cell array of concept name extracts a list for that
%     subset of concepts only.
%
%   'imageLimit'
%     Together with a number, it selects an as big subset of dataset
%     images.
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
        
        % extracting images list and the list of images path was requested for
        imagesList = {obj.imageData.fileName};
        
        [~, subsetData, ~] = cellfun(@(x)(fileparts(x)), subsetData, 'UniformOutput',false);
        
        % checking for errors on the subset of images
        assert(all(ismember(subsetData, imagesList)),'Some of the requested images are not in the images folder. Check for spelling or for file location.');
        
        % generating paths
        imagesPaths = cellfun(@(x)(fullfile(obj.sourceData{1}{2}, [x,'.jpg'])), subsetData, 'UniformOutput',false)';
        
    elseif strcmpi(subsetType,'conceptNames')
        
        % extracting names from the list of concepts we want images for
        conceptNames = subsetData;
        
        % checking for errors on the subset of concepts
        assert(all(ismember(conceptNames,obj.conceptList)),'Some selected concepts are not in the list of possible concepts.')
        
        % determining the indexes of imageData entries which contain the requested list of concepts
        idxs = cellfun(@(x)(ismember(x(1,:),conceptNames)), {obj.imageData.annotation}, 'UniformOutput', false)';
        idxs = cellfun(@(x)(any(x)), idxs);
        
        % extracting paths for the just determined indexes
        imagesPaths = cellfun(@(x)(fullfile(obj.sourceData{1}{2},[x,'.jpg'])), {obj.imageData(idxs).fileName}, 'UniformOutput', false)';
        
        % loop version
        % i = 1;
        % for j = 1:length(obj.imageData)
            % objectNames = obj.imageData(j).annotation(1,:);
            
            % if ~any(ismember(objectNames,conceptNames))
                % continue
            % end
            
            % imagesPaths{i,1} = fullfile(obj.sourceData{1}{2},[obj.imageData(j).fileName,'.jpg']);
            % i = i + 1;
        % end

        
    elseif strcmpi(subsetType, 'imageLimit')
        
        if subsetData > 0
            
            % extracting complete list of images paths and related indexes
            imagesPaths = cellfun(@(x)(fullfile(obj.sourceData{1}{2},[x,'.jpg'])), {obj.imageData.fileName}, 'UniformOutput', false)';
            idxs = 1:length(imagesPaths);
            
            % misuse warning
            if subsetData > length(idxs)
                warning('Image limit exceeds dataset dimension: no discount will be applied.');
                pause(3);
            end
            
            % randomizing indexes and picking the requested number
            idxs = vl_colsubset(idxs, subsetData);
            
            % fetching the requested number of random images' path
            imagesPaths = imagesPaths(idxs);
        else
            
            % misuse warning
            warning('Image limit is not a positive integer: no discount will be applied.');
            pause(3);
            
            % images paths for the complete dataset
            imagesPaths = cellfun(@(x)(fullfile(obj.sourceData{1}{2},[x,'.jpg'])), {obj.imageData.fileName}, 'UniformOutput', false)';
        end
        
    else
        % checking for correct input
        error('Make sure you choose either fileNames or conceptNames option, followed by a 1xN cell array where N is the number of elements of the required list.')
    end
else
    % images paths for the complete dataset
    imagesPaths = cellfun(@(x)(fullfile(obj.sourceData{1}{2},[x,'.jpg'])), {obj.imageData.fileName}, 'UniformOutput', false)';
end
end