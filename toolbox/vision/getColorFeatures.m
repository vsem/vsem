function [feats, frames, imsize] = getColorFeatures(image)
% Read and convert image to double precision
% image = im2double(cfext.readImage(imagePath));
% % image = im2double(image);

imsize = size(image);
fprintf('herexxxxxxxxxxxxx');

% Check if the image is a truecolor M-by-N-by-3 array
if size(image, 3) == 1
    err = MException('VSEM:FeatExt', 'Grayscale image: %s', ...
        imagePath);
    throw(err)
end


% Extract colour descriptors
[desc, info] = Image2ColourNamePatches(image, 6, 4);

feats = desc';

% Convert center point locations of local patches to format
% used by VLFeat and other parts of VSEM
frames(1,:) = info.col';
frames(2,:) = info.row';

features.frame = cat(2, frames{:});
features.descr = cat(2, feats{:});

end % compute


end % methods