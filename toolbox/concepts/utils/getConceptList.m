function conceptList = getConceptList(conceptSpace)
% getConceptList concept list for the concept conceptSpace
%   getConceptList(obj) returns the 1xN cell array of concepts in
%   the concepts conceptSpace.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

conceptList = conceptSpace.conceptIndex.keys;