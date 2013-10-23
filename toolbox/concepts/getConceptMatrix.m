function conceptMatrix = getConceptMatrix(space, varargin)
% conceptMatrix concept matrix for the concept space
%   getConceptMatrix(obj, 'optionName', 'optionValue') returns, by
%   default, the complete visual concept matrix for concept space.
%   Alternatively, it returns the matrix for the concept or cell
%   array of concepts it was requested for.


if nargin == 1
    % returning the complete matrix by default
    conceptMatrix = space.conceptMatrix;
elseif nargin == 2
    % checking for errors in the input list
    assert(all(isConcept(varargin{:})), 'Some of the selected concepts are not in the concept space.');
    
    % standardizing input for one single concept list
    if ischar(varargin{:}), varargin = {varargin}; end
    
    % extracting indexes and matrix for the selected concepts
    idxs = space.conceptIndex.values(varargin{:});
    idxs = cat(1,idxs{:});
    
    conceptMatrix = space.conceptMatrix(:,idxs);
else
    % checking for invalid input
    error('Invalid input argument. Select a single concept or a cell array of concepts. Default: complete matrix.')
end