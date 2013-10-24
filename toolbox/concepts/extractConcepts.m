function conceptSpace = extractConcepts(encoder, imagePaths, annotations, conceptList, varargin)
% extractConcepts concept extractor main utility
%   extractConcepts(imagePaths, annotations, conceptList, 'optionName',
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
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.localization = 'global';

opts.verbose = false;
opts = vl_argparse(opts, varargin);
opts.conceptHistParams = {'localization', opts.localization};
conceptSpace=1;

% Check if we have the same number of images and corresponding tags
assert(length(imagePaths) == length(annotations), ...
    'Number of images does not match the number of annotations');

if opts.verbose
    % settings for progress bar graphics and variables
    text = 'Extracting concepts: ';
    barColor = [0.76 0.24 0.45];
    waitBar = helpers.graphics.WaitBar(length(imagePaths), text, barColor);
end

conceptMatrixInitialized = false;
% extracting concepts over the whole selected set of images
for i = 1:size(imagePaths, 1)
    
    if opts.verbose
        % handle for cancel button on progress bar
        if ~waitBar.textualVersion && getappdata(waitBar.bar,'canceling')
            break
        end
        
        % updating waitbar
        waitBar.update(i);
    end
    
    try
        % extracting histogram and object list for the ith image
        
        [histogram, objectList] = extractConceptHistogram(encoder, ...
                                                          imagePaths{i}, ...
                                                          annotations{i}, ...
                                                          opts.conceptHistParams{:});
        
        if ~conceptMatrixInitialized
            % initializing concept matrix with histogram dimension
            conceptSpace.conceptMatrix = zeros(length(histogram), length(conceptList));
            conceptSpace.conceptIndex = containers.Map(conceptList, 1:length(conceptList));
            conceptMatrixInitialized = true;
        end
        
        % pdating concept space with the previously extracted data
        conceptSpace = updateConceptMatrix(conceptSpace, histogram, objectList);
        
    catch ME
        switch ME.identifier
            case 'VSEM:FeatExt'
                fprintf(1, '%s\n', ME.message);
            otherwise
                fprintf(1, 'Error reading file: %s\n', imagePaths{i});
        end
    end % try-catch block
end % image iteration


% -------------------------------------------------------------------------
function conceptSpace = updateConceptMatrix(conceptSpace, histogram, objectList, varargin)
% -------------------------------------------------------------------------
% update concept conceptSpace aggregator
%   update(conceptSpace, histogram, objectList, varargin) aggregates one 
%   or more histograms 'histogram' to a list of objects 'objectList' 
%   of the same size, or aggregates one histogram to a list of 
%   objects, regardless the size of the latter. It returns the updated 
%   object.

opts.aggregationFn = @sumFn;
opts = vl_argparse(opts,varargin) ;

% extracting and cleaning index list for the selected list of objects
idxs = conceptSpace.conceptIndex.values(objectList);
idxs = cat(2, idxs{:});

% aggregating the new histogram matrix with the histograms already computed
updatedMatrix = opts.aggregationFn(conceptSpace.conceptMatrix, histogram, idxs);

% assigning back updated matrix
conceptSpace.conceptMatrix(:,idxs) = updatedMatrix;