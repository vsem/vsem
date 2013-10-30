function path = vsem_setup(varargin)
% vsemStartup Add VSEM Toolbox to the MATLAB path
%   path = vsem_setup() adds the VSEM Toolbox to MATLAB path and
%   returns the path PATH to the VSEM package.
%
%   See also: vsem_root().

% Authors: Elia Bruni and Ulisse Bordignon
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

quiet = true ;

for ai=1:length(varargin)
    opt = varargin{ai} ;
    switch lower(opt)
        case {'quiet'}
            quiet = true ;
        case {'verbose'}
            quiet = false ;
        otherwise
            error('Unknown option ''%s''.', opt) ;
    end
end

if exist('vl_version') == 3
    version = vl_version;
    if strcmp(version, '0.9.17')
        % Get the actual path
        [a,~,~] = fileparts(mfilename('fullpath'));
        [a,~,~] = fileparts(a);
        root = a;
        
        % Add VSEM to the matlab path
        addpath(fullfile(root,'toolbox')) ;
        addpath(fullfile(root,'toolbox','concepts')) ;
        addpath(fullfile(root,'toolbox','concepts','utils')) ;
        addpath(fullfile(root,'toolbox','vision')) ;
        addpath(fullfile(root,'toolbox','transformations')) ;
        addpath(fullfile(root,'toolbox','benchmarks')) ;
        
        if ~quiet
            if exist('vsem_version') == 2
                vsemVersion = vsem_version;
                fprintf('VSEM %s ready.\n', vsemVersion) ;
            else
                error('VSEM does not seem to be installed correctly. Please download the last version of VSEM at http://clic.cimec.unitn.it/vsem and try again.') ;
            end
        end
    else
        error('VLFeat 0.9.17 does not seem to be installed. VSEM cannot run without VLFeat 0.9.17, plase install it (see http://www.vlfeat.org/) and run vsem_setup again.') ;
        
    end
else
    warning('VLFeat does not seem to be installed correctly. Make sure that the MEX files are compiled.') ;
end



if nargout == 0
    clear path ;
end

