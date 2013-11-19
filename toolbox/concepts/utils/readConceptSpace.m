function conceptSpace = readConceptSpace(filePath, varargin)
% readConceptSpace Read a concept space from file
%   readConceptSpace(filePath, varargin) reads an ASCII file in the format
%
%   concept1 feature1 feature2, ..., featureN
%   concept2 feature1 feature2, ..., featureN
%   ...      ...      ...            ...
%   conceptM feature1 feature2, ..., featureN
%
%  Options:  
%
%  numberOfFeatures:: []
%   If you specify the number of features might be slightly faster.
% 

% Authors: Irina Sergienya, Elia Bruni
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.numberOfFeatures = [];
opts = vl_argparse(opts, varargin);

disp('Start reading the concept space...');

if isempty(opts.numberOfFeatures)
    fileID = fopen(filePath);
    conceptList = textscan(fileID,'%s %*[^\n]');
    fclose(fileID);
    conceptList = conceptList{:};
    conceptSpace.conceptMatrix = dlmread(filePath, ' ', 0,1)';
    conceptSpace.conceptIndex = containers.Map(conceptList, 1:length(conceptList));
else
    % format string to get features from file
    f = repmat([' %f'], 1, opts.numberOfFeatures-1);
    featuresFormatString = strcat('%*s %f', f);
    featuresFormatString = strcat(featuresFormatString, '\n');
    
    % format string to print word and its features
    sf = repmat([' %f'], 1, opts.numberOfFeatures-1);
    formatString = strcat('%s %f', sf);
    formatString = strcat(formatString, '\n');
    
    % create cell array for the list of words
    conceptList = cell(1, 1);
    
    i = 1; %number of the entry in matrix
    j = 1; %number of the line in the file fidMatrix
    
    % read file line by line
    fidMatrix = fopen (filePath, 'r');
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
    
    conceptSpace.conceptMatrix = conceptMatrix';
    conceptSpace.conceptIndex = containers.Map(conceptList, 1:length(conceptList));
end