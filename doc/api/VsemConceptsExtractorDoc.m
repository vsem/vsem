%% concepts.extractor.VsemConceptsExtractor class
%
% *Package:* concepts.extractor
%
% <html>
% <span style="color:#666">Extract visual concepts</span>
% </html>
%
%% Description
%
% |concepts.extractor.VsemConceptsExtractor| serves as a handle 
% for the extractConcepts method, which is responsible for the
% construction of ConceptSpace from a certain dataset of annotated images
% and with a certain histogram extractor.
%
%
%% Construction
%
% |vsemConceptsExtractor = concepts.extractor.VsemConceptsExtractor('optionName', 'optionValue')|
%
%
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
%
% |subbin_norm_type| Normalization for sub bins of a concept. The possible
% values are: |'none'| (default), |'l1'| and |'l2'|.
% 
% |norm_type| Normalization for sub bins of a concept. The possible
% values are: |'none'| (default), |'l1'| and |'l2'|.
% 
% |post_norm_type| Normalization for sub bins of a concept. The possible
% values are: |'none'| (default), |'l1'| and |'l2'|.
% 
% |kermap| Normalization for sub bins of a concept. The possible
% values are: |'none'| (default), |'homker'| and |'hellinger'|.
% 
%
%% Properties
%
% |extractorConfiguration| Contains the configuration options of the class.
%
%
%% Methods
%
% |conceptSpace = extractConcepts(dataset, histogramExtractor, 'optionName','optionValue')|
% builds a concept space from the |dataset| using |histogramExtractor| to obtain bovw histograms
% for every image in the dataset. In returns the concept space itself.
%