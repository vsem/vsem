function combinedSpace = concatSpaces(space1, space2)
% concat Cocatenate two concept spaces
%	combinedSpace = concat(conceptSpace1, conceptSpace2) 
% combines two concept spaces via concatenation. 
% First, only the concepts that are in common between the two
% given concept spaces are retained. Second, the vectors of the two concept
% spaces are independently normalized (v/norm(v)). Finally, the two concept
% matrices are concatenated and a new concept space is generated.

% Authors: A1
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

% Get only those concepts which are shared across the two concept spaces.
commonConcepts = intersect(getConceptList(space1), getConceptList(space2));

% Get the concept matrix of both concept spaces.
conceptMatrix1 = getConceptMatrix(space1, commonConcepts);
conceptMatrix2 = getConceptMatrix(space2, commonConcepts);

% Normalize the visual vectors by computing v/norm(v) for each vector.
normalizedMatrix1 = normc(conceptMatrix1);
normalizedMatrix2 = normc(conceptMatrix2);


% Create a new concept space resulting from the combination of the given
% concept spaces. Note that only those concepts that are in common between
% the two concept spaces are retained.
combinedSpace.conceptMatrix = [normalizedMatrix1;normalizedMatrix2];
combinedspce.containers.Map(commonConcepts, 1:length(commonConcepts));
