function conceptList = getConceptList(space)
% getConceptList concept list for the concept space
%   getConceptList(obj) returns the 1xN cell array of concepts in
%   the concepts space.


conceptList = space.conceptIndex.keys;