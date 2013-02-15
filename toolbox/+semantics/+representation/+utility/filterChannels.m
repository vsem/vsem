function [commonConcepts, vectors1, vectors2] = filterChannels(concepts1, vectors1, concepts2, vectors2)
%
%
%
%
%
%
%   
%

% -------------------------------------------------------------------
%
% -------------------------------------------------------------------
 
  % get the 2 intersections (boolean)
  
  intersection1 = ismember(concepts1, concepts2) ;
  intersection2 = ismember(concepts2, concepts1) ;
  
 
  % filter the two channels
  commonConcepts = concepts1(intersection1, :) ;
  vectors1 = vectors1(intersection1, :) ;
  vectors2 = vectors2(intersection2, :) ;
  

 
 
 
 

 
 
 
 


