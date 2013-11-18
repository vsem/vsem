function [feats, frames, imsize] = getColorFeatures(image)
% Read and convert image to double precision
% image = im2double(cfext.readImage(imagePath));
% % image = im2double(image);

imsize = size(image);

% Check if the image is a truecolor M-by-N-by-3 array
if size(image, 3) == 1
    err = MException('VSEM:FeatExt', 'Grayscale image: %s', ...
        imagePath);
    throw(err)
end


% Extract colour descriptors
[desc, info] = cfext.Image2ColourNamePatches(image, 6, 4);

feats = desc';

% Convert center point locations of local patches to format
% used by VLFeat and other parts of VSEM
frames(1,:) = info.col';
frames(2,:) = info.row';

features.frame = cat(2, frames{:});
features.descr = cat(2, feats{:});

end % compute

function  [desc info] = Image2ColourNamePatches(cfext, imrgb, numPixels, numBins);
info = ConcatenateInfo(cfext, infoIn);
m = DiagMatrixLinear(cfext,a,b);
[feature info] = Feature2Spatial(cfext,featureIn, infoIn, s);
info = GetDenseInfoStructure(cfext,imSize, n, m, regionSize, offset);
[features info] = Image2DenseColourNamePatches(cfext,im, nP);
b = NormalizeRows(cfext,a, n);
cNames = Rgb2ElevenColourNames(cfext,im, do3D);

end % methods