function reweightedVectors = vsem_reweightVectors(vectors, scores)
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

  % extract the bovw histograms and the scores only and convert
  % them to matrix
  %vectors = cell2mat(conceptBovwHistograms(:,2)) ;
  %scores = cell2mat(conceptScores(:,2)) ;
  
  reweightedVectors = zeros(size(vectors,1), size(vectors,2)) ;
  
  % reweight the vector after normalizing it to unit length.
  for i = 1:size(vectors,1)
    vector = vectors(i,:) ;  
    normalizedVector = vector/norm(vector) ;
    reweightedVectors(i,:) = (normalizedVector .* scores(i)) ;
  end
  
  % create the reweighted conceptBovwHistograms concatenating concepts and 
  % the newly created vectors
  
  %reweightedVectors = [conceptBovwHistograms(:,1),mat2cell(reweightedBovwHistograms,ones(2,1))] ;
  
  