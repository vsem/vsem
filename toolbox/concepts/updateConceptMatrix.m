function space = updateConceptMatrix(space, histogram, objectList, varargin)
% update concept space aggregator
%   update(obj, histogram, objectList) aggregates one or more histograms
%   'histogram' to a list of objects 'objectList' of the same size, or
%   aggregates one histogram to a list of objects, regardless the size of
%   the latter. It returns the updated object.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.aggregationFn = @sumFn;
opts = vl_argparse(opts,varargin) ;

% extracting and cleaning index list for the selected list of objects
idxs = space.conceptIndex.values(objectList);
idxs = cat(2, idxs{:});

% aggregating the new histogram matrix with the histograms already computed
updatedMatrix = opts.aggregationFn(space.conceptMatrix, histogram, idxs);

% assigning back updated matrix
space.conceptMatrix(:,idxs) = updatedMatrix;
