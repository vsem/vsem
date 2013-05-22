function obj = normalize(obj, normSize, normType)
% normalize normalization utility for the concept space
%   normalize(obj, normSize, normType) normalizes the entire concept matrix
%   given a certain "size" 'normSize', that is bins- or whole image-wise
%   and a certain type 'normType'. The returning object can be assigned
%   back to the original one or to a new one to preserve the original data.
%
%   Input:
%
%   'normSize'
%     Either 'l1' or 'l2'.
%
%   'normType'
%     Either 'bins' or 'whole'.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


% checking for input errors
assert(any(strcmpi(normSize, obj.normalizationSize)), 'Normalization size must be either ''whole'' or ''bins''');
assert(any(strcmpi(normType, obj.normalizationType)), 'Normalization type must be either ''l1'' or ''l2''');

switch lower(normSize)
    
    % bins size
    case 'bins'
        for i = 1:size(obj.conceptMatrix,2)
            switch lower(normType)
                
                % normalizing
                case 'l1'
                    normConcept = sum(obj.conceptMatrix(:,i), 1);
                    normConcept = max(normConcept, eps);
                    obj.conceptMatrix(:,1) = bsxfun(@times, obj.conceptMatrix(:,i), 1 ./ normConcept);
                case 'l2'
                    normConcept = sqrt(sum(obj.conceptMatrix(:,i) .^ 2, 1));
                    normConcept = max(normConcept, eps);
                    obj.conceptMatrix(:,1) = bsxfun(@times, obj.conceptMatrix(:,i), 1 ./ normConcept);
            end
        end
        
    % whole size
    case 'whole'
        for i = 1:size(obj.conceptMatrix,2)
            
            % normalizing
            switch lower(normType)
                case 'l1'
                    obj.conceptMatrix(:,i) = obj.conceptMatrix(:,i)/norm(obj.conceptMatrix(:,i),1);
                case 'l2'
                    obj.conceptMatrix(:,i) = obj.conceptMatrix(:,i)/norm(obj.conceptMatrix(:,i),2);
            end
        end
end
end
