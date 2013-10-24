function idxs = isConcept(conceptSpace, conceptList)
% isConcept concept conceptSpace handling utility
%   isConcept(obj, conceptList) determines which concepts in the
%   cell array 'conceptList' are in the concept conceptSpace. Returns a
%   logical array.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).
idxs = conceptSpace.conceptIndex.isKey(conceptList);