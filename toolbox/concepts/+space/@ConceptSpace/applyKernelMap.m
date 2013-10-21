function obj = applyKernelMap(obj, kernelMap)
% applyKernelMap kernel map utility for concept space
%   applyKernelMap(obj, kernelMap) applies the requested kernel map
%   'kernelMap' to the concept space matrix. Output can be returned to the
%   original data or to a new object.
%
%   Input:
%
%   'kernelMap':
%     Map type, either 'homker' or 'hellinger'.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


% checking for input errors
assert(any(strcmpi(kernelMap, obj.kernels)), 'Kernel map must be either ''homker'' or ''hellinger''');

switch lower(kernelMap)
    % homker kernel map
    case 'homker'
        for i = 1:size(obj.conceptMatrix,2)
            newMatrix(:,i) = vl_homkermap(obj.conceptMatrix(:,i), 1, 'kchi2');
        end
        obj.conceptMatrix = newMatrix;
        
    % hellinger kernel map
    case 'hellinger'
        for i = 1:size(obj.conceptMatrix,2)
            obj.conceptMatrix(:,i) = sign(obj.conceptMatrix(:,i)) .* sqrt(abs(obj.conceptMatrix(:,i)));
        end
end
end