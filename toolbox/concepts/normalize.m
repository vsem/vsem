function matrix = normalize(matrix, normSize, normType)
% normalize normalization utility for a matrix
%   normalize(obj, normSize, normType) normalizes the entire matrix
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

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).


% checking for input errors
%assert(any(strcmpi(normSize, obj.normalizationSize)), 'Normalization size must be either ''whole'' or ''bins''');
%assert(any(strcmpi(normType, obj.normalizationType)), 'Normalization type must be either ''l1'' or ''l2''');

switch lower(normSize)
    
    % bins size
    case 'bins'
        for i = 1:size(matrix,2)
            switch lower(normType)
                
                % normalizing
                case 'l1'
                    normConcept = sum(matrix(:,i), 1);
                    normConcept = max(normConcept, eps);
                    matrix(:,1) = bsxfun(@times, matrix(:,i), 1 ./ normConcept);
                case 'l2'
                    normConcept = sqrt(sum(matrix(:,i) .^ 2, 1));
                    normConcept = max(normConcept, eps);
                    matrix(:,1) = bsxfun(@times, matrix(:,i), 1 ./ normConcept);
            end
        end
        
    % whole size
    case 'whole'
        for i = 1:size(matrix,2)
            
            % normalizing
            switch lower(normType)
                case 'l1'
                    matrix(:,i) = matrix(:,i)/norm(matrix(:,i),1);
                case 'l2'
                    matrix(:,i) = matrix(:,i)/norm(matrix(:,i),2);
            end
        end
end
end