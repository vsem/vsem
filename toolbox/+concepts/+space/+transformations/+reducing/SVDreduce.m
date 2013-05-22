function reducedM = SVDreduce(M, numDim)
% SVDreduce SVD reduces the given matrix
%	SVDreduce(M, numDim) Performs truncated Singular Value Decomposition 
%   to a reduced dimension 'numDim' on the given matrix 'M'. 
%   

% Authors: A1
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).
    [U,S,~] = svds(M, numDim);
    reducedM = U*S;
end

