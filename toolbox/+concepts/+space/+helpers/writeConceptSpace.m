function writeConceptSpace(conceptSpace, fileName)
% writeConceptSpace Write a concept space into file
%	writesConceptSpace(conceptSpace, fileName) writes a concept space into 
%   ASCII file in the format
%
%   concept1 feature1 feature2, ..., featureN
%   concept2 feature1 feature2, ..., featureN
%   ...      ...      ...            ...
%   conceptM feature1 feature2, ..., featureN
%

% Authors: A1
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

disp('Saving ConceptSpace into file...');

fidSave = fopen (fileName, 'w');

% format string to print word and its features
sf = repmat([' %f'], 1, length(conceptSpace.conceptMatrix)-1);
formatString = strcat('%s %f', sf);
formatString = strcat(formatString, '\n');

for concept = conceptSpace.getConceptList
    fprintf(fidSave, formatString, concept{:}, conceptSpace.getConceptMatrix(concept));
end
fclose(fidSave);

%file loadMatrixWordsList_out.mat - for matlab representation
%save('loadMatrixWordsList_out.mat', 'wordsList', 'featureMatrix');

disp('ConceptSpace saved succesfully.');