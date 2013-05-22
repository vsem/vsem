function combinedConceptSpace = concat(conceptSpace1, conceptSpace2)
% concat Cocatenate two concept spaces
%	combinedConceptSpace = concat(conceptSpace1, conceptSpace2) 
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
commonConcepts = intersect(conceptSpace1.getConceptList(), conceptSpace2.getConceptList());

% Get the concept matrix of both concept spaces.
matrix1 = conceptSpace1.getConceptMatrix(commonConcepts);
matrix2 = conceptSpace2.getConceptMatrix(commonConcepts);

% Normalize the visual vectors by computing v/norm(v) for each vector.
normalizedMatrix1 = normc(matrix1);
normalizedMatrix2 = normc(matrix2);

% Concatenate the normalized matrices.
combinedMatrix = [normalizedMatrix1;normalizedMatrix2];

% Create a new concept space resulting from the combination of the given
% concept spaces. Note that only those concepts that are in common between
% the two concept spaces are retained.
combinedConceptSpace = concepts.space.ConceptSpace(commonConcepts, combinedMatrix);

end