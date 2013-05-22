fprintf('\nInstalling VSEM toolbox...\n\n');

untar('http://www.vlfeat.org/download/vlfeat-0.9.16-bin.tar.gz','temp');
movefile(fullfile(pwd,'temp/vlfeat-0.9.16'), fullfile(pwd,'../lib'));

delete(fullfile(pwd,'temp/*')); rmdir('temp');

try
    run(fullfile(pwd,'../lib/gmm-fisher/matlab/setup.m'));
catch
    fprintf('\nInstallation was unable to compile part of the library.\nAll VSEM functionalities are working, except for the Fisher library.\nBeware: Fisher functionalities are available for linux and some windows architecture only.\nUpdates will be provided soon. Please check on VSEM website http://clic.cimec.unitn.it/vsem/download.html for updates.\n\n');
end
