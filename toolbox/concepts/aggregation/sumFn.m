function conceptMatrix = sumFn(conceptMatrix, histogram, idxs)
% SUMFN aggregation
%	sumFn(conceptMatrix, histogram, idxs) aggregates the matrix 
%   'histogram' to the matrix 'conceptMatrix' for the
%   'idxs' indexes and returns the updated conceptMatrix.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

conceptMatrix = bsxfun(@plus,conceptMatrix(:,idxs),histogram);