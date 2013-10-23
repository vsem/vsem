function conceptList = getConceptList(space)
% getConceptList concept list for the concept space
%   getConceptList(obj) returns the 1xN cell array of concepts in
%   the concepts space.
%

% Author: Ulisse Bordignon

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

conceptList = space.conceptIndex.keys;