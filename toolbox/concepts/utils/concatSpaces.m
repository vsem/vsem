function combinedSpace = concatSpaces(conceptSpace1, conceptSpace2)
% concat Cocatenate two conceptSpaces
%	combinedconceptSpace = concat(conceptSpace1, conceptSpace2) 
% combines two conceptSpaces via concatenation. 
% First, only the concepts that are in common between the two
% given conceptSpaces are retained. Second, the vectors of the two
% conceptSpaces are independently normalized (v/norm(v)). Finally, the two
% matrices are concatenated and a new conceptSpace is generated.
%

% Author: Elia Bruni

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

% Get only those concepts which are shared across the two concept conceptSpaces.
commonConcepts = intersect(getConceptList(conceptSpace1), getConceptList(conceptSpace2));

% Get the concept matrix of both concept conceptSpaces.
conceptMatrix1 = getConceptMatrix(conceptSpace1, commonConcepts);
conceptMatrix2 = getConceptMatrix(conceptSpace2, commonConcepts);

% Normalize the visual vectors by computing v/norm(v) for each vector.
normalizedMatrix1 = normc(conceptMatrix1);
normalizedMatrix2 = normc(conceptMatrix2);


% Create a new concept conceptSpace resulting from the combination of the given
% concept conceptSpaces. Note that only those concepts that are in common between
% the two concept conceptSpaces are retained.
combinedSpace.conceptMatrix = [normalizedMatrix1;normalizedMatrix2];
combinedSpace.conceptIndex = containers.Map(commonConcepts, 1:length(commonConcepts));
