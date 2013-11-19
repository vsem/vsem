fprintf('\nDownloading and installing Pascal dataset...\n\n');

untar('http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2012/VOCtrainval_11-May-2012.tar','temp');
movefile(fullfile(vsem_root,'temp/VOCdevkit/VOC2012/JPEGImages'), fullfile(vsem_root,'data'));
movefile(fullfile(vsem_root,'temp/VOCdevkit/VOC2012/Annotations'), fullfile(vsem_root,'data'));

delete(fullfile(vsem_root,'temp','*')); rmdir('temp');

fprintf('\nDone!\n\n');