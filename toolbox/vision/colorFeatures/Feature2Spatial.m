function [feature info] = Feature2Spatial(featureIn, infoIn, s)
% [feature info] = Feature2Spatial(featureIn, infoIn)
%
% Creates spatial version of the feature elements.
%
% featureIn:            N x M Features that serve as building blocks
% infoIn:               Info structure belonging to the features. Contains
%                       coordinates and amount of horizontal and vertical
%                       building blocks.
% s:                    Spatiality. For normal SIFT/SURF this is 4.
% 
% feature:              N x (s x s x M) output features.
% info:                 New info structure containing coordinates only
%                       (Necessary for spatial pyramid

n = infoIn.n; % number of building blocks in row direction
m = infoIn.m;

% Determine which building blocks need to be taken together
indices = 1:(n*m);
indices = reshape(indices, n, m);

coordinates = cell(1,s*s);
idx = 1;
for j=1:s
    for i=1:s
        coordinates{idx} = indices(i:(end-s+i), j:(end-s+j));
        coordinates{idx} = coordinates{idx}(:);
        idx = idx + 1;
    end
end

% Put all coordinates underneath each other
coordsFinal = cat(1, coordinates{:});

% Get features. Notice that the reshape does not alter the way memory
% is allocated
feature = featureIn(coordsFinal, :);
feature = reshape(feature, [], size(featureIn,2) * s * s);


%%%%%%%%%%%%%%
% Info structure
%%%%%%%%%%%%%%

% Copy info structure
info = infoIn;

% Get coordinates of the features
r = infoIn.row(coordsFinal);
r = reshape(r, [], s * s);
info.row = mean(r,2);

c = infoIn.col(coordsFinal);
c = reshape(c, [], s * s);
info.col = mean(c,2);

% regionSize
info.regionSize = infoIn.regionSize * s;

% New n and m
info.n = info.n - s + 1;
info.m = info.m - s + 1;

info.numDescriptors = length(info.row);