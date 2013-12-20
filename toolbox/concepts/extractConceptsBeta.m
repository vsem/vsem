function conceptSpace = extractConcepts(encoder, imagePaths, annotations, conceptList, typeOfCalc, varargin)
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

% Author: Ulisse Bordignon and Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


opts.localization = 'global';

opts.verbose = false;
opts = vl_argparse(opts, varargin);
opts.conceptHistParams = {'localization', opts.localization};

disp('Extract concepts options:' ); disp(opts);

% Check if we have the same number of images and corresponding tags
assert(length(imagePaths) == length(annotations), ...
    'Number of images does not match the number of annotations');

if opts.verbose
    % settings for progress bar graphics and variables
    text = 'Extracting concepts: ';
    barColor = [0.76 0.24 0.45];
    waitBar = helpers.graphics.WaitBar(length(imagePaths), text, barColor);
end

conceptSpace=[];
conceptMatrixInitialized = false;

if (strcmpi(typeOfCalc,'normal'))

	% extracting concepts over the whole selected set of images
	for i = 1:size(imagePaths, 1)
		conceptName = annotations{i}(1);
		if  any(strcmp(conceptName, conceptList))
			
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
				% ----- can objectList have more than one object? -- yes
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
				
				% updating concept space with the previously extracted data
				conceptSpace = updateConceptMatrix(conceptSpace, histogram, objectList);
				%conceptList
				
			catch ME
				switch ME.identifier
					case 'VSEM:FeatExt'
						fprintf(1, '%s\n', ME.message);
					otherwise
						fprintf(1, 'Following error while reading file: %s\n', imagePaths{i});
						fprintf(1, '%s\n', ME.message);
				end
			end % try-catch block
		end
	end % image iteration


else
	hist_length = size(encoder.subdivisions,2).*encoder.numWords;
	conceptSpace.conceptMatrix = zeros(hist_length, length(conceptList));
	conceptSpace.conceptIndex = containers.Map(conceptList, 1:length(conceptList));
	conceptMatrixInitialized = true;
	% counting 
	counterList = zeros(length(conceptList),1);
	mean = zeros(hist_length, length(conceptList));
	M2 = zeros(hist_length, length(conceptList));

	for i = 1:size(imagePaths, 1)
			
		conceptName = annotations{i}(1);	
		if  any(strcmp(conceptName, conceptList))
			
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
				
				% clear index
				idxs = conceptSpace.conceptIndex.values(objectList);
				idxs = cat(2, idxs{:});
				
				% using 
				for k = 1 : length(idxs)			
						
					id = idxs(k);
					% update counterList					
					counterList(id) = counterList(id) + 1;   % n = n + 1											
					
					% compute % delta = x - mean
					% delta = bsxfun(@minus,histogram(:,k),mean(:,id));     
					delta = histogram(:,k) - mean(:,id);
					
					% comopte delta/n
					% delta_byN = bsxfun(@rdivide,delta,counterList(id)); 
					delta_byN = delta/counterList(id);
								
					% update mean  mean = mean + delta_byN
					% updatedMean = bsxfun(@plus,mean(:,id),delta_byN);  
					updatedMean = mean(:,id) + delta_byN;  
					mean(:,id) = updatedMean; 
								
					% compute x - mean
					% x_mean = bsxfun(@minus,histogram(:,k),updatedMean);
					x_mean = histogram(:,k) - updatedMean;
				
					% compute delta*(x-mean)
					%delta_x_mean = bsxfun(@times,delta,x_mean);
					delta_x_mean = delta.*x_mean;
				
					% compute M2 (incremental mean)
					% updatedM2 = bsxfun(@plus,M2(:,id),delta_x_mean);
					updatedM2 = M2(:,id) + delta_x_mean;
					M2(:,id) = updatedM2;							
					
				end			             
				
			catch ME
				switch ME.identifier
					case 'VSEM:FeatExt'
						fprintf(1, '%s\n', ME.message);
					otherwise
						fprintf(1, 'Following error while reading file: %s\n', imagePaths{i});
						fprintf(1, '%s\n', ME.message);
				end
			end % try-catch block
		end	  
		
	end % image iteration

	%return conceptSpance here
	if (strcmpi(typeOfCalc,'increMean'))
		% for the incremental Mean
		conceptSpace.conceptMatrix = M2; %variance = M2/(n - 1)
	else
		% compute the incremental std: variance = M2/(n - 1)
		counterList_ = counterList';
		idsx_ = find(counterList_);
				
		updatedM2_ = bsxfun(@rdivide, M2(:,idsx_),counterList_(idsx_));
		M2(:,idsx_) = updatedM2_;
		conceptSpace.conceptMatrix = sqrt(M2);	
	end
	
end


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