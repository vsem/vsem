function updatedMatrix = sumFn(conceptMatrix,histogram,idxs)
% sum Sum aggregation
%	sum(M1, M2, idxs) aggregates the matrix 'M1' to the matrix 'M2' for the
%   'idxs' indexes and returns the updated matrix.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

updatedMatrix = bsxfun(@plus,conceptMatrix(:,idxs),histogram);