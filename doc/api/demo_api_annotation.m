%% concepts.helpers.AssociationMeasure class
%
% *Package:* concepts
%
% <html>
% <span style="color:#666">Compute association measures</span>
% </html>
%
%% Description
%
% The |concepts.helpers.AssociationMeasure| transforms the frequency counts
% of a given matrix to the specified association scores. 
% The available association measures are Pointwise Mutual Information (*PMI*)
% and Local Mutual Information (*LMI*), where
%
% $$PMI(t,c) =\log{\frac{\mathrm{P}(t,c)}{\mathrm{P}(t)\mathrm{P}(c)}}$$ 
%
% and
%
% $$LMI(t,c) = \mathrm{Count}(t,c)\times{}\log{\frac{\mathrm{P}(t,c)}{\mathrm{P}(t)\mathrm{P}(c)}}$$
%
%
%% Construction
%
% |associationMeasure = concepts.helpers.AssociationMeasure('OptionName', optionValue,...)|
%
%
%
%% Input Arguments
%
% The behaviour of this class can be adjusted by modifying the following options:
%
% |Verbose| Set to false to turn off verbose output. The possible values
% are |'true'| (default), |'false'|.
% 
%
% |Measure| The name of the similarity benchmark to use. The possible
% values are |'pmi'| (default), |'lmi'|.
% 
%% Properties
%
% |options| Contain the options of the class
%
%
%% Methods
%
% |M = compute(obj, M)| Compute the chosen association score for the given matrix
%
%% Examples
%
%
% *This is the title of example1*
%
% This is the description of the example
%
% *This is the title of example2*
%
% This is the description of the example