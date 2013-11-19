function features = getColorFeatures(image)

% Extract colour descriptors
[desc, info] = Image2ColourNamePatches(image, 6, 4);

feats = desc';

% Convert center point locations of local patches to format
% used by VLFeat and other parts of VSEM
frames(1,:) = info.col';
frames(2,:) = info.row';


features.frame = frames;
features.descr = feats;

end