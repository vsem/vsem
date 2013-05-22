function conceptSpace = readConceptSpace(fileName, numberOfFeatures)
% readConceptSpace Read a concept space from file
%	readConceptSpace(fileName, numberOfFeatures) reads an ASCII file in the format
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

disp('Start reading the concept space...');

% format string to get features from file
f = repmat([' %f'], 1, numberOfFeatures-1);
featuresFormatString = strcat('%*s %f', f);
featuresFormatString = strcat(featuresFormatString, '\n');

% format string to print word and its features
sf = repmat([' %f'], 1, numberOfFeatures-1);
formatString = strcat('%s %f', sf);
formatString = strcat(formatString, '\n');

% create cell array for the list of words
conceptList = cell(1, 1);

i = 1; %number of the entry in matrix
j = 1; %number of the line in the file fidMatrix

% read file line by line
fidMatrix = fopen (fileName, 'r');
tline = fgetl(fidMatrix);

while (ischar(tline))
    %parse the tline to get information
    
    % get word
    conceptList{i, 1} = strtok(tline);
    % get features
    conceptMatrix(i, :) = sscanf(tline, featuresFormatString);
    
    i = i + 1;
    % print process
    if (mod(i, 1000) == 0)
        fprintf('%d...', i);
    end
    tline = fgetl(fidMatrix);
end

fclose (fidMatrix);
fprintf('\nFinished file processing.\n');

conceptMatrix = conceptMatrix';
conceptSpace = concepts.space.ConceptSpace(conceptList, conceptMatrix);


end