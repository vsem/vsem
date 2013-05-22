classdef VsemDataset
% VsemDataset dataset resources handling
%   VsemDataset(imagesPath, 'optionName', 'optionValue') constructs an
%   object that contains path and annotation data for the dataset of images
%   in 'imagesPath' folder, as well as the list of concepts the annotation
%   data encompasses.
%   
%   The following options are available:
%
%   'annotationType':: 'completeAnnotation'
%      Type of annotation input. 
%
%      'completeAnnotation'
%         Complete xml annotation of the images, bearing localization, is
%         available. Requires 'annotationFolder' option and value.
%
%      'conceptFile'
%         A single .txt file recording, for each line, the name of a
%         concept and the images tagged with that concept. Requires
%         'annotationFile' option and value.
%
%      'imageFile'
%         A single .txt file recording, for each line, the name of an image
%         and the concepts which are tags for/objects into that image.
%         Requires 'annotationFile' option and value.
%
%      'conceptfolder'
%         Images are arranged, inside the imagesPath folder, in subfolders
%         named with the tag/object their images content represents.
%
%      'descFiles'
%         For each image in the image folder ('imagesPath/filename.jpg')
%         there is a corresponding annotation file with concepts, one at a 
%         line ('annotationFolder/filename.jpg.desc'). Requires
%         'annotationFolder' option and value.
%
%   The dateset is accessible with two methods:
%
%   getImagesPaths('optionName', 'optionValue') extracts a cell array of
%   image paths on which further computation can be done (e.g. imread)
%
%   getAnnotatedImages('optionName', 'optionValue') extracts a double cell
%   array with image paths and annotation data.
%
%   Options list:
%   
%   'fileNames'
%     Followed by a 1xN cell array of file name strings extracts a list for
%     that subset of images only.
%
%   'conceptNames'
%     Followed by a 1xN cell array of concept name extracts a list for
%     that subset of concepts only.
%
%   'imageLimit'
%     Together with a number, it selects an as big subset of random dataset
%     images.
%
%   No input
%     Returns complete set.
%
%
%   The input of this methods is refined if it is a file list or treated
%   case insensitively if it is a concept list, to guarantee a degree of
%   smoothness and less effort to produce such lists.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


    properties (SetAccess = protected)
        imageData
        sourceData
        conceptList
        datasetOptions = struct(...
            'annotationType', 'completeAnnotation');
    end
    
    properties (Constant, Hidden)
        annotationTypes = {'completeAnnotation', 'conceptFile', ...
            'imageFile', 'conceptFolder', 'descFiles'};
    end
    
    methods
        function obj = VsemDataset(imagesPath, varargin)
            
            % parsing input for options
            [obj.datasetOptions, varargin] = vl_argparse(obj.datasetOptions, varargin);
            
            % checking whether the correct options have been chosen and if the images folder exists
            assert(any(strcmpi(obj.datasetOptions.annotationType, obj.annotationTypes)), 'Select either ''completeAnnotation'', ''conceptFile'', ''imageFile'', ''conceptFolder'' or ''descFiles''  annotation type.');
            assert(any(exist('imagesPath')), 'The selected images folder does not exist');
            
            switch lower(obj.datasetOptions.annotationType)
                case 'completeannotation'
                    
                    % checking for correct input and assigning it to source data
                    assert(strcmpi(varargin{1}, 'annotationFolder') && exist(varargin{2}, 'dir'), 'For ''completeAnnotation'' provide the parameter ''annotationFolder'' with the selected path as a value.');
                    obj.sourceData = {{'Images path', imagesPath},{'Annotations path', varargin{2}}};
                    
                    % launching preparaImages method
                    [obj.imageData, obj.conceptList] = obj.prepareImages();
                    
                case {'conceptfile', 'imagefile'}
                    
                    % checking for correct input and assigning it to source data
                    assert(strcmpi(varargin{1}, 'annotationFile') && exist(varargin{2}, 'file'), 'Provide the parameter ''annotationFile'' with its path as a value.');
                    obj.sourceData = {{'Images path', imagesPath},{'Annotation path', varargin{2}}};
                    
                    % launching preparaImages method
                    [obj.imageData, obj.conceptList] = obj.prepareImages();
                    
                case 'conceptfolder'
                    % assigning input to source data
                    obj.sourceData = {{'Images path', imagesPath}};
                    
                    % launching preparaImages method
                    [obj.imageData, obj.conceptList] = obj.prepareImages();

                case 'descfiles'
                    
                    % checking for correct input and assigning it to source data
                    assert(strcmpi(varargin{1}, 'annotationFolder') && ...
                        exist(varargin{2}, 'dir'), ...
                        ['For ''descFiles'' provide the parameter', ... 
                        '''annotationFolder'' with the selected path as', ...
                       ' a value.']);
                    obj.sourceData = {{'Images path', imagesPath}, ...
                        {'Annotations path', varargin{2}}};
                    
                    % launching preparaImages method
                    [obj.imageData, obj.conceptList] = obj.prepareImages();
                     
            end
        end

        imagesPaths = getImagesPaths(obj, varargin)
        
        annotatedImages = getAnnotatedImages(obj, varargin)
    end
    
    methods (Access = protected)
        [imageData, conceptList] = prepareImages(obj)
    end
end
