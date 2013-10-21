function path = vsemStartup(varargin)
% vsemStartup Add VSEM Toolbox to the MATLAB path
%   path = vsemStartup() adds the VSEM Toolbox to MATLAB path and
%   returns the path PATH to the VSEM package.
%
%   See also: vsemRoot().

% Authors: Elia Bruni and Ulisse Bordignon
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

% Get the actual path 
[a,~,~] = fileparts(mfilename('fullpath'));
[a,~,~] = fileparts(a);
root = a;

% Add VSEM to the matlab path
addpath(fullfile(root,'toolbox'));


% Add VLFeat to the matlab path
run(fullfile(root,'lib/vlfeat-0.9.17/toolbox/vl_setup'));

if nargout == 0
  clear path ;
end

