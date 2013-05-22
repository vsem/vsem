%% datasets.VsemDataset class
%
% *Package:* datasets
%
% <html>
% <span style="color:#666">Handle dataset resources</span>
% </html>
%
%% Description
%
% |datasets.VsemDataset| constructs an object that contains path and 
% annotation data for the dataset of images in |imagesPath| folder, 
% as well as the list of concepts the annotation data encompasses.
%
%
%% Construction
%
% |vsemDataset = datasets.VsemDataset('OptionName', optionValue,...)|
%
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
%
% |AnnotationType| Type of annotation input. The possible annotation inputs are:
% |'completeAnnotation'| (Complete xml annotation of the images, bearing localization, is
% available. Requires |'annotationFolder'| option and value); 
% |'imageFile'| (A single .txt file recording, for each line, the name of an image
% and the concepts which are tags for/objects into that image.
% Requires |'annotationFile'| option and value.); |'conceptfolder'| 
% (Images are arranged, inside the imagesPath folder, in subfolders
% named with the tag/object their images content represents).
%
%
%% Properties
%
% |imageData| The image data arranged in vsem format.
%
% |sourceData| The initial image data.
%
% |conceptList| The list of concepts.
%
% |datasetOptions| The options for this class.
%
%
%% Methods
%
% |imagesPaths = getImagesPaths('optionName', 'optionValue')| Extract a cell array of
%   image paths on which further computation can be done (e.g. imread).
% The possible options are: |'fileNames'| (Followed by a cell array of 
% file name strings extracts a list for
% that subset of images only); |'conceptNames'| (Followed by a cell array of 
% concept names extracts a list for that subset of concepts only); 
% |'imageLimit'| (Together with a number, it selects an as big subset of 
% random dataset images). With no options returns the complete set.
% 
% |getAnnotatedImages('optionName', 'optionValue')| Extract a double cell
% array with image paths and annotation data. The possible options are:
% |'fileNames'| (Followed by a cell array of file name strings extracts a list for
% that subset of images only); |'conceptNames'| (Followed by a cell array of 
% concept names extracts a list for that subset of concepts only); 
% |'imageLimit'| (Together with a number, it selects an as big subset of 
% random dataset images). With no options returns the complete set.
%
%