function [imagePaths, annotations, conceptList] = readDataset(varargin)
% readDataset dataset reader
%
%   READDATASET(..., 'OPT', VAL, ...) accepts the following options:
%
%   inputFormat:: 'completeAnnotation'
%
%      The following input types are available:
%
%      'completeAnnotation'
%         Complete xml annotation of the images, bearing localization, is
%         available. Requires 'annotationFolder' option and value.
%
%      'conceptFile'
%         A single .txt file recording, for each line, the name of a
%         concept and the images tagged with that concept.
%
%      'conceptfolder'
%         Images are arranged, inside the imagesPath folder, in subfolders
%         named with the tag/object their images content represents.
%
%      'imageFile'
%         A single .txt file recording, for each line, the name of an image
%         and the concepts which are tags for/objects into that image.
%
%      'descFiles'
%         For each image in the image folder ('imagesPath/filename.jpg')
%         there is a corresponding annotation file with concepts, one at a
%         line ('annotationFolder/filename.jpg.desc').

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.inputFormat = 'completeAnnotation';
opts.imageDir = '';
opts.annotations = '';
opts.filemask = '.*(jpg|JPEG|gif)';
opts.maxNumTrainImagesPerConcept = Inf;

opts = vl_argparse(opts, varargin);

disp('Dataset options:' ); disp(opts);

switch opts.inputFormat
    case 'completeAnnotation'
        % complete list of images from the images database
        imagePaths = listFiles(opts.imageDir, opts.filemask);
        
        % initializing annotations and concept list
        annotations = cell(1, length(imagePaths));
        conceptList = {};
        
        % iterating over the set of images
        for i = 1:length(imagePaths)
            % building path for annotation and determining whether such file exists
            [~, filename, ~] = fileparts(imagePaths{i});
            annotationPath = fullfile(opts.annotations, [filename '.xml']);
            assert(any(exist(annotationPath, 'file')), ...
                'No annotation file %s was located', annotationPath);
            
            % extracting annotation
            annotationFile = readXML(annotationPath);
            
            try
                % extracting the objects' list for the ith image
                objectNames = {annotationFile.annotation.object.name};
                annots = cell(2, length(objectNames));
                
                % iterating over the set of objects
                for j = 1:length(objectNames)
                    
                    
                    % object name for the kth object
                    objectName = objectNames{j};
                    
                    % if not yet recorded, adding the object name to the concept list
                    if all(~strcmp(objectName,conceptList))
                        conceptList{end+1,1} = objectName;
                    end
                    
                    % assigning to the ith entry in the dataset the
                    % object name and its bounding box
                    annots{1,j} = objectName;
                    
                    xmin = str2double(annotationFile.annotation.object(j).bndbox.xmin);
                    xmax = str2double(annotationFile.annotation.object(j).bndbox.xmax);
                    ymin = str2double(annotationFile.annotation.object(j).bndbox.ymin);
                    ymax = str2double(annotationFile.annotation.object(j).bndbox.ymax);
                    
                    annots{2,j} = [xmin xmax ymin ymax];
                end
                annotations{i} = annots;
            catch ME
                fprintf('Following problem for annotation file %s:\n',annotationPath);
                fprintf(1, '%s\n', ME.message);
            end
        end
        % sorting concepts
        conceptList = sort(conceptList);
        
    case 'conceptFile'
        
        % if the input is a file, open, read the file and extract
        % annotation from it
        annotationFile = fopen(opts.annotations);
        lines = textscan(annotationFile,'%s','delimiter', '\n');
        fclose(annotationFile);
        lines = cellfun(@(x)(textscan(x,'%s','delimiter', ' ')), ...
            lines{:}, 'UniformOutput', false);
        lines = cat(1, lines{:});
        
        % initializing concept list and determining the number of
        % concepts
        imagePaths = {};
        annotations = {};
        conceptsNumber = length(lines);
        conceptList = {};
        
        % iteration over the number of concepts
        for i = 1:conceptsNumber
            % extracting annotation and updating concept list
            conceptName = lines{i}{1};
            conceptList{end+1,1} = conceptName;
            
            % filepaths of images under this concept
            conceptImages = cellfun(@(x)(fullfile(opts.imageDir, x)), ...
                lines{i}(2:end), 'UniformOutput', false);
            
            if ~(isempty(conceptImages))
                % indexes for images that are and are not already in the output list
                newImageIdxs = ismember(conceptImages, imagePaths) == 0;
                usedImageIdxs = find(ismember(imagePaths, conceptImages));
                
                % for 'conceptFile' annotation type, checking that the
                % images in the annotation file do exist on the provided path
                assert(all(cellfun(@(x)(exist(x,'file')), conceptImages)), ...
                    'Some of the images listed in the annotation file are missing from the images folder, possible spelling error or deleted image.');
                
                % updating imageData with the new images
                imagePaths = vertcat(imagePaths, ...
                    conceptImages(newImageIdxs));
                annotations(end+1:length(imagePaths)) = {conceptName};
                
                % updating annotation for and assigning back those entries which are already in imageData
                oldannots = annotations(usedImageIdxs);
                newannots = cellfun(@(x)(horzcat(x, {conceptName})), ...
                    oldannots, 'UniformOutput', false);
                
                annotations(usedImageIdxs) = newannots;
            else
                conceptList{i} = [];
                conceptList(~cellfun('isempty',conceptList));
            end
        end
        % sorting concepts
        conceptList = sort(conceptList);
        
    case 'conceptFolder'
        
        % if the input is a folder with one subfolder for each tag,
        % determining concept list from these along with their number
        names = dir(opts.imageDir) ;
        names = {names([names.isdir]).name} ;
        conceptList = setdiff(names, {'.', '..'}) ;
        
        % iteration over the number of concepts
        imagePaths = {};
        annotations = {};
        overallLength = 0;
        for c = 1:length(conceptList)
            % extracting concept name and associated images
            concept = conceptList{c};
            tmp = dir(fullfile(opts.imageDir, [concept filesep '*.jpg']));
            paths = strcat([fullfile(opts.imageDir,'/') concept filesep], {tmp.name});
            
            % add only those concepts which have at least one image
            if ~(isempty(paths))
                % select a random subset of all the images for this concept
                if ~isinf(opts.maxNumTrainImagesPerConcept)
                    ids = vl_colsubset(1:length(paths), opts.maxNumTrainImagesPerConcept);
                    paths = paths(ids);
                end
                imagePaths{c} = paths;
                overallLength = overallLength + length(imagePaths{c});
                annotations(end+1:overallLength) = {{concept}};
            else
                conceptList{c} = [];
                conceptList = conceptList(~cellfun('isempty',conceptList));
            end
        end
        
        imagePaths = cat(2,imagePaths{:});
        imagePaths = imagePaths(:);
        % sorting concepts
        conceptList = sort(conceptList);
        
    case 'conceptFolderWithRepetition'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WARNING: The execution of this code might be very slow if      %
        % the dataset to be read is too large.                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % if the input is a folder with one subfolder for each tag,
        % determining concept list from these along with their number
        conceptFolders = dir(opts.imageDir);
        properFolders = [conceptFolders(:).isdir];
        conceptFolders = {conceptFolders(properFolders).name}';
        
        conceptFolders(ismember(conceptFolders,{'.','..'})) = [];
        conceptList = conceptFolders;
        conceptsNumber = length(conceptList);
        
        % initializing
        imagePaths = {};
        annotations = {};
        
        % iteration over the number of concepts
        for i = 1:conceptsNumber
            fprintf('Now indexing concept number %i of %d...\n',i,conceptsNumber);
            % extracting concept name and associated images
            conceptName = conceptList{i};
            
            images = listFiles(fullfile(opts.imageDir, ...
                conceptName), opts.filemask);
            
            [~, conceptImageNames, ~] = cellfun(@fileparts, images, ...
                'UniformOutput', false);
            if ~isempty(imagePaths)
                [~, usedImageNames, ~]  = cellfun(@fileparts, ...
                    imagePaths, 'UniformOutput', false);
            else
                usedImageNames = {};
            end
            
            % indexes for images that are and are not already in the output list
            newImageIdxs = ismember(conceptImageNames, usedImageNames) == 0;
            usedImageIdxs = find(ismember(usedImageNames, conceptImageNames));
            
            newImagePaths = images(newImageIdxs);
            
            if ~(isempty(newImagePaths))
                % updating imageData with the new images
                imagePaths = vertcat(imagePaths, newImagePaths);
                annotations(end+1:length(imagePaths)) = {conceptName};
                
                
                % updating annotation for and assigning back those
                % entries which are already in imageData
                annots = annotations(usedImageIdxs);
                annots = cellfun(@(x)(horzcat(x, {conceptName})), ...
                    annots, 'UniformOutput', false);
                
                annotations(usedImageIdxs) = annots;
                
            else
                conceptList{i} = [];
                conceptList(~cellfun('isempty',conceptList));
            end
        end
        % sorting concepts
        conceptList = sort(conceptList);
        
    case 'imageFile'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WARNING: This reading option doesn't support                   %
        % opts.doubleCheckImages yet.                                    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % opening, reading the annotation file and extracting annotation
        % and images list from it
        annotationFile = fopen(opts.annotations);
        annotation = textscan(annotationFile,'%s','delimiter', '\n');
        fclose(annotationFile);
        annotation = cellfun(@(x)(textscan(x,'%s','delimiter', ' ')), ...
            annotation{:}, 'UniformOutput', false);
        annotation = cat(1, annotation{:});
        
        imagePaths = cellfun(@(x) (fullfile(opts.imageDir,x{1})), ...
            annotation, 'UniformOutput', false);
        
        
        % initializing
        conceptList = {};
        
        % iterating on the whole set of images (in the annotation file)
        for i = 1:length(annotation)
            % extracting and assigning objects to the image they belong to
            objectNames = annotation{i}(2:end);
            annotations{i} = objectNames';
            
            % updating conceptList with the set of new concepts
            newConcepts = ismember(objectNames, conceptList) == 0;
            conceptList = cat(1, conceptList, objectNames(newConcepts));
        end
        % sorting concepts
        conceptList = sort(conceptList);
        
    case 'descFiles'
        % read all images in the image folder
        imagePaths  = listFiles(opts.imageDir, opts.filemask);
        
        % initializing concept list
        conceptList = {};
        
        % initialize
        annotations = {};
        
        % iterating over the set of images
        for i = 1:length(imagePaths)
            
            % building path for annotation and determining whether such file exists
            [~ , filename, ~]  = fileparts(imagePaths{i});
            annotationPath = fullfile(opts.annotations, ...
                [filename '.desc']);
            
            if exist(annotationPath, 'file')
                % extracting and assigning objects to the image they belong to
                annotationFile = fopen(annotationPath);
                scan = textscan(annotationFile, '%s', 'Delimiter', '\n');
                objectNames = scan{1};
                fclose(annotationFile);
                
                annotations{i} = objectNames';
                
                % updating conceptList with the set of new concepts
                newConcepts = ismember(objectNames, conceptList) == 0;
                conceptList = cat(1, conceptList, objectNames(newConcepts));
            else
                fprintf(1, 'Description file does not exist: %s\n', ...
                    annotationPath);
            end
        end
        
        % sorting concepts
        conceptList = sort(conceptList);
        
end % switch


end % prepareImages


% -------------------------------------------------------------------------
function filelist = listFiles(directory, mask)
% -------------------------------------------------------------------------
% Return list of full paths to files in a directory
% whose filenames match the given mask

filelist = dir(directory); % list folder content
filelist = {filelist([filelist.isdir] == 0).name}; % keep only files
filelist = regexpi(filelist, mask,'match'); % match filenames
% remove filenames that didn't match and transpose to make
% a Nx1 cell array
filelist = [filelist{:}]';
filelist = cellfun(@(x)(fullfile(directory, x)), filelist, ...
    'UniformOutput', false);
end % readFiles
