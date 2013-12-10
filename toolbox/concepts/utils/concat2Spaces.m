function conceptSpace = concat2Spaces(conceptSpace1, conceptSpace2)

% WARNING: that's ad hoc code to concat two spaces, but need
% a lot of checking before making it official

conceptList=[conceptSpace1.conceptIndex.keys,conceptSpace2.conceptIndex.keys];
conceptSpace.conceptIndex = containers.Map(conceptList, 1:length(conceptList));

conceptSpace.conceptMatrix=horzcat(conceptSpace1.conceptMatrix, conceptSpace2.conceptMatrix);

