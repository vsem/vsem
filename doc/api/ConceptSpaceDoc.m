%% concepts.ConceptSpace class
%
% *Package:* concepts
%
% <html>
% <span style="color:#666">Visual concept vectors handling facility</span>
% </html>
%
%% Description
%
% |concepts.ConceptSpace| builds the concept handling class for the concepts 
% in the |conceptList| cell array and with vectors of size |outputDimension|, 
% which is responsible for updating (aggregation), normalizing, applying a kernel
% map to, reweighting and reducing the visual concept vectors. Moreover,
% it allows concept list and matrix displaying methods and the isConcept
% method, which provides a way to check if a concept is in the concept
% space.
%
%
%% Construction
%
% |conceptSpace = ConceptSpace(conceptList, outputDimension, 'optionName', 'optionValue')|
%
%
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
%
% |aggregatorFunction| Aggregator function handle. The possible
% values are: |@concepts.space.aggregator.sum| (default).
% 
% |reweightingFunction| Reweighting function handle. The possible
% values are: |@concepts.space.transformations.reweighting.lmiReweight| (default), 
% |@concepts.space.transformations.reweighting.pmiReweight|.
% 
% |reducingFunction| Reducing function handle. The possible
% values are: |@concepts.space.transformations.reducing.SVDreduce| (default).
% 
% |readFromFile| Reads the concept space from a file and requires a cell array with
% the file path and the number of features for that file, in this
% order. Set |conceptList| and |outputDimension| to |'none'|.
% 
% 
%
%% Properties
%
% |conceptIndex| The mapping between concept names and concept vectors.
%
% |conceptMatrix| The concept vectors.
%
% |options| Contains the configuration options of the class.
%
%
%% Methods
%
% |conceptSpace = reweight(dimensions, 'optionName', 'optionValue')|
% reduces the concept matrix to 'dimensions' dimension. A default
% reducing function is provided and can be reviewed in the
% |options| property of the object. Reduced matrix can be
% reassigned to the original object or to a new one to preserve
% original data.
% Options: |reducingFunction| Handle to the reducing function. The possible
% values are: |@concepts.space.transformations.reducing.SVDreduce|
% (dafault).
% 
% |idxs = isConcept(conceptList)| determines which concepts in the
% cell array |conceptList| are in the concept space. Returns a
% logical array.
%
% |conceptList = getConceptList()| returns the 1xN cell array of concepts in
% the concepts space.
%
% |conceptMatrix = getConceptMatrix('optionName', 'optionValue')| returns, by
% default, the complete visual concept matrix for concept space.
% Alternatively, it returns the matrix for the concept or cell
% array of concepts it was requested for.
% 