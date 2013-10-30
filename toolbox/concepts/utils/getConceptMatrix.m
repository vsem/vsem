function conceptMatrix = getConceptMatrix(conceptSpace, varargin)
% conceptMatrix concept matrix for the concept conceptSpace
%   getConceptMatrix(obj, 'optionName', 'optionValue') returns, by
%   default, the complete visual concept matrix for concept conceptSpace.
%   Alternatively, it returns the matrix for the concept or cell
%   array of concepts it was requested for.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


if nargin == 1
    % returning the complete matrix by default
    conceptMatrix = conceptSpace.conceptMatrix;
elseif nargin == 2
    % checking for errors in the input list
   % assert(all(isConcept(varargin{:})), 'Some of the selected concepts are not in the concept conceptSpace.');
    
    % standardizing input for one single concept list
    if ischar(varargin{:}), varargin = {varargin}; end
    
    % extracting indexes and matrix for the selected concepts
    idxs = conceptSpace.conceptIndex.values(varargin{:});
    idxs = cat(1,idxs{:});

    conceptMatrix = conceptSpace.conceptMatrix(:,idxs);
else
    % checking for invalid input
    error('Invalid input argument. Select a single concept or a cell array of concepts. Default: complete matrix.')
end