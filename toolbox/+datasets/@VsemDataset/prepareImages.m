function [imageData, conceptList] = prepareImages(obj)
    % prepareImages prepare input for VsemDataset constructor
    %   prepareImages(obj) is the main method for the class constructor of
    %   VsemDataset. It handles all five possible inputs, 'completeAnnotation',
    %   'imageFile', 'conceptFile', 'conceptFolder' and 'descFiles'. It returns 'imageData',
    %   a structure containing 'fileName', the name of the images without
    %   extension, 'annotation', a list of objects/tags and, if available (so
    %   just for 'completeAnnotation'), localization, for each image in the
    %   dataset. Lastly 'conceptList', the list of concepts whose single
    %   instances (objects/tags) were found in the dataset.
    %
    %
    % Authors: A2
    %
    % AUTORIGHTS
    %
    % This file is part of the VSEM library and is made available under
    % the terms of the BSD license (see the COPYING file).


    switch lower(obj.datasetOptions.annotationType)
        case 'completeannotation'
            % complete list of images from the images database
            imagePaths = listFiles(obj.sourceData{1}{2}, obj.filemask);

            % setting filePath field of imageData
            imageData = struct('filePath', imagePaths);

            % settings for progress bar graphics and variables
            text = 'Preparing dataset: ';
            barColor = [0.26 0 0.51];
            waitBar = helpers.graphics.WaitBar(length(imageData), text, barColor);

            % initializing concept list
            conceptList = {};

            % iterating over the set of images
            for i = 1:length(imageData)

                % updating waitbar
                waitBar.update(i);

                % building path for annotation and determining whether such file exists
                [~, filename, ~] = fileparts(imageData(i).filePath);
                annotationPath = fullfile(obj.sourceData{2}{2}, [filename '.xml']);
                assert(any(exist(annotationPath, 'file')), ...
                    'No annotation file %s was located', annotationPath);

                % extracting annotation
                annotationFile = datasets.helpers.readXML(annotationPath);

                % extracting the objects' list for the ith image
                objectNames = {annotationFile.annotation.object.name};

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
                    imageData(i).annotation{1,j} = objectName;

                    xmin = str2double(annotationFile.annotation.object(j).bndbox.xmin);
                    xmax = str2double(annotationFile.annotation.object(j).bndbox.xmax);
                    ymin = str2double(annotationFile.annotation.object(j).bndbox.ymin);
                    ymax = str2double(annotationFile.annotation.object(j).bndbox.ymax);

                    imageData(i).annotation{2,j} = [xmin xmax ymin ymax];
                end

                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    imageData = imageData(1:i);
                    return
                end
            end

            % sorting concepts
            conceptList = sort(conceptList);

        case 'conceptfile'

            % if the input is a file, open, read the file and extract annotation from it
            annotationFile = fopen(obj.sourceData{2}{2});
            lines = textscan(annotationFile,'%s','delimiter', '\n');
            fclose(annotationFile);
            lines = cellfun(@(x)(textscan(x,'%s','delimiter', ' ')), ...
                lines{:}, 'UniformOutput', false);
            lines = cat(1, lines{:});

            % initializing concept list and determining the number of concepts
            conceptsNumber = length(lines);
            conceptList = {};

            % initializing
            imageData = struct('filePath', {}, 'annotation', {});

            % setting for progress bar graphics and variables
            text = 'Preparing dataset: ';
            barColor = [0.26 0 0.51];
            waitBar = helpers.graphics.WaitBar(conceptsNumber, text, barColor);

            % iteration over the number of concepts
            for i = 1:conceptsNumber

                % updating waitbar
                waitBar.update(i);

                % extracting annotation and updating concept list
                conceptName = lines{i}{1};
                conceptList{end+1,1} = conceptName;

                % filepaths of images under this concept
                imagePaths = cellfun(@(x)(fullfile(obj.sourceData{1}{2}, x)), ...
                    lines{i}(2:end), 'UniformOutput', false);

                usedImages = {imageData.filePath};

                % indexes for images that are and are not already in the output list
                newImageIdxs = ismember(imagePaths, usedImages) == 0;
                usedImageIdxs = find(ismember(usedImages, imagePaths));

                % for 'conceptFile' annotation type, checking that the images in the annotation file do exist on the provided path
                assert(all(cellfun(@(x)(exist(x,'file')), imagePaths)), ...
                    'Some of the images listed in the annotation file are missing from the images folder, possible spelling error or deleted image.');

                % updating imageData with the new images
                imageData = [imageData; ... 
                    struct('filePath', imagePaths(newImageIdxs), ...
                    'annotation', {{conceptName}})];

                % updating annotation for and assigning back those entries which are already in imageData
                annotations = {imageData(usedImageIdxs).annotation};
                annotations = cellfun(@(x)(cat(2, x, conceptName)), ...
                    annotations, 'UniformOutput', false);

                imageData(usedImageIdxs) = struct('filePath', ...
                    {imageData(usedImageIdxs).filePath}, 'annotation', annotations);

                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    return
                end
            end

            % sorting concepts
            conceptList = sort(conceptList);

        case 'conceptfolder'
            % if the input is a folder with one subfolder for each tag,
            % determining concept list from these along with their number
            conceptFolders = dir(obj.sourceData{1}{2});
            properFolders = [conceptFolders(:).isdir];
            conceptFolders = {conceptFolders(properFolders).name}';

            conceptFolders(ismember(conceptFolders,{'.','..'})) = [];
            conceptList = conceptFolders;
            conceptsNumber = length(conceptList);

            % initializing
            imageData = struct('filePath', {}, 'annotation', {});

            % setting for progress bar graphics and variables
            text = 'Preparing dataset: ';
            barColor = [0.26 0 0.51];
            waitBar = helpers.graphics.WaitBar(conceptsNumber, text, barColor);

            % iteration over the number of concepts
            for i = 1:conceptsNumber

                % updating waitbar
                waitBar.update(i);


                % extracting concept name and associated images
                conceptName = conceptList{i};

                imagePaths = listFiles(fullfile(obj.sourceData{1}{2}, ...
                    conceptName), obj.filemask);

                [~, conceptImageNames, ~] = cellfun(@fileparts, imagePaths, ...
                    'UniformOutput', false);
                [~, usedImageNames, ~]  = cellfun(@fileparts, {imageData.filePath}, ...
                    'UniformOutput', false);

                % indexes for images that are and are not already in the output list
                newImageIdxs = ismember(conceptImageNames, usedImageNames) == 0;
                usedImageIdxs = find(ismember(usedImageNames, conceptImageNames));

                % paths of new images
                newImagePaths = imagePaths(newImageIdxs);
                
                % updating imageData with the new images
                imageData = [imageData; ...
                    struct('filePath', imagePaths(newImageIdxs), ...
                    'annotation', {{conceptName}})];

                % updating annotation for and assigning back those
                % entries which are already in imageData
                annotations = {imageData(usedImageIdxs).annotation};
                annotations = cellfun(@(x)(cat(2, x, conceptName)), ...
                    annotations, 'UniformOutput', false);

                imageData(usedImageIdxs) = struct('filePath', ...
                    {imageData(usedImageIdxs).filePath}, 'annotation', annotations);

                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    return
                end
            end

            % sorting concepts
            conceptList = sort(conceptList);

        case 'imagefile'

            % opening, reading the annotation file and extracting annotation 
            % and images list from it
            annotationFile = fopen(obj.sourceData{2}{2});
            annotation = textscan(annotationFile,'%s','delimiter', '\n');
            fclose(annotationFile);
            annotation = cellfun(@(x)(textscan(x,'%s','delimiter', ' ')), ...
                annotation{:}, 'UniformOutput', false);
            annotation = cat(1, annotation{:});

            imageData = struct('filePath', cellfun(@(x) ...
                (fullfile(obj.sourceData{1}{2},x{1})), annotation, ...
                'UniformOutput', false));

            % checking that the images in the annotation file do exist on the 
            % provided path
            assert(all(cellfun(@(x)(exist(x,'file')),{imageData.filePath})), ...
                'Some of the images listed in the annotation file are missing from the images folder, possible spelling error or deleted image.');

            % initializing
            conceptList = {};

            % setting for progress bar graphics and variables
            text = 'Preparing dataset: ';
            barColor = [0.26 0 0.51];
            waitBar = helpers.graphics.WaitBar(length(imageData), text, barColor);

            % iterating on the whole set of images (in the annotation file)
            for i = 1:length(annotation)

                % updating waitbar
                waitBar.update(i);

                % extracting and assigning objects to the image they belong to
                objectNames = annotation{i}(2:end);
                imageData(i).annotation = objectNames';

                % updating conceptList with the set of new concepts
                newConcepts = ismember(objectNames, conceptList) == 0;
                conceptList = cat(1, conceptList, objectNames(newConcepts));

                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    return
                end

            end

            % sorting concepts
            conceptList = sort(conceptList);

        case 'descfiles'
            % read all images in the image folder
            imageData  = struct('filePath', ...
                listFiles(obj.sourceData{1}{2}, obj.filemask));

            % settings for progress bar graphics and variables
            text = 'Preparing dataset: ';
            barColor = [0.26 0 0.51];
            waitBar = helpers.graphics.WaitBar(length(imageData), text, barColor);

            % initializing concept list
            conceptList = {};

            % iterating over the set of images
            for i = 1:length(imageData)

                % updating waitbar
                waitBar.update(i);

                % building path for annotation and determining whether such file exists
                [~ , filename, ~]  = fileparts(imageData(i).filePath);
                annotationPath = fullfile(obj.sourceData{2}{2}, ...
                    [filename '.desc']);
                assert(any(exist(annotationPath, 'file')), ...
                    'No annotation file %s was located', annotationPath);

                % extracting and assigning objects to the image they belong to
                annotationFile = fopen(annotationPath);
                scan = textscan(annotationFile, '%s', 'Delimiter', '\n');
                objectNames = scan{1};
                fclose(annotationFile);
                imageData(i).annotation = objectNames';

                % updating conceptList with the set of new concepts
                newConcepts = ismember(objectNames, conceptList) == 0;
                conceptList = cat(1, conceptList, objectNames(newConcepts));

                % handle for cancel button on progress bar
                if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
                    imageData = imageData(1:i);
                    return
                end
            end

            % sorting concepts
            conceptList = sort(conceptList);

    end % switch

    function filelist = listFiles(directory, mask)
        % return list of full paths to files in a directory 
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
        
end % prepareImages
