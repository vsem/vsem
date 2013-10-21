function conceptSpace = updateConceptMatrix(conceptSpace, histogram, objectList)
% update concept space aggregator
%   update(obj, histogram, objectList) aggregates one or more histograms
%   'histogram' to a list of objects 'objectList' of the same size, or
%   aggregates one histogram to a list of objects, regardless the size of
%   the latter. It returns the updated object.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

%opts.aggregatorFunction = @sum;


% extracting and cleaning index list for the selected list of objects
idxs = conceptSpace.conceptIndex.values(objectList);
idxs = cat(2, idxs{:});

% aggregating the new histogram matrix with the histograms already computed
updatedMatrix = bsxfun(@plus,conceptSpace.conceptMatrix(:,idxs),histogram);
%updatedMatrix = opts.aggregatorFunction(conceptSpace.conceptMatrix, histogram, idxs);

% assigning back updated matrix
conceptSpace.conceptMatrix(:,idxs) = updatedMatrix;
end
