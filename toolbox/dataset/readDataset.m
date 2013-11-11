function [imagePaths, annotations, conceptList] = readDataset(varargin)

    opts.annotationType = 'completeAnnotation';
    opts.imageDir = '';
    opts.annotations = '';
    opts.filemask = '.*(jpg|gif)';

    opts = vl_argparse(opts, varargin);

    switch opts.annotationType
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
            end
            % sorting concepts
            conceptList = sort(conceptList);

        case 'conceptFolder'
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

                % paths of new images
                newImagePaths = images(newImageIdxs);
                
                % updating imageData with the new images
                imagePaths = vertcat(imagePaths, images(newImageIdxs));
                annotations(end+1:length(imagePaths)) = {conceptName};

                % updating annotation for and assigning back those
                % entries which are already in imageData
                annots = annotations(usedImageIdxs);
                annots = cellfun(@(x)(horzcat(x, {conceptName})), ...
                    annots, 'UniformOutput', false);
                annotations(usedImageIdxs) = annots; 
            end
            % sorting concepts
            conceptList = sort(conceptList);

        case 'imageFile'

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
