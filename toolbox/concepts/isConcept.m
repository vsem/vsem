function idxs = isConcept(space, conceptList)
% isConcept concept space handling utility
%   isConcept(obj, conceptList) determines which concepts in the
%   cell array 'conceptList' are in the concept space. Returns a
%   logical array.


idxs = space.conceptIndex.isKey(conceptList);