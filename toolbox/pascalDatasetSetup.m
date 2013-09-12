fprintf('\nDownloading and installing Pascal dataset...\n\n');

untar('http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2012/VOCtrainval_11-May-2012.tar','temp');
movefile(fullfile(vsemRoot,'temp/VOCdevkit/VOC2012/JPEGImages'), fullfile(vsemRoot,'data'));
movefile(fullfile(vsemRoot,'temp/VOCdevkit/VOC2012/Annotations'), fullfile(vsemRoot,'data'));

delete(fullfile(vsemRoot,'temp','*')); rmdir('temp');

fprintf('\nDone!\n\n');