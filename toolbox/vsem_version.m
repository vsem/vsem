function version = vsem_version(varargin)
% vsemStartup Add VSEM Toolbox to the MATLAB path
%   vsem_version() prints the VSEM version installed on this machine.
%
%   See also: vsem_setup().

% Authors: Elia Bruni
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

version = '0.2';
extendedVersion = 'VSEM version 0.2';

if nargin == 1
    opt = varargin{1};
    
    if strcmp(lower(opt), 'verbose')
    disp(extendedVersion);
    
    else
        error('Unknown option ''%s''.', opt) ;
    end
    
end