function reducedMatrix = SVDreduce(matrix, numDim)
% SVDreduce SVD reduces the given matrix
%	SVDreduce(matrix, numDim) Performs truncated Singular Value Decomposition
%   to a reduced dimension 'numDim' on the given matrix 'matrix'.
%

% Authors: Elia Bruni
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

[U,S,~] = svds(matrix', numDim);
reducedMatrix = U*S;
reducedMatrix = reducedMatrix';