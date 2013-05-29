% function [desc info] = Image2ColourNamePatches(imrgb, numPixels, numBins)
%
% Converts an image to local colour name patches (11 colour names, Weijer,
% Trans. on Image Processing, 2011). Does this at 5 scales. 
%
% imrgb:        rgb image (double)
% numPixels:    Number of pixels per bin (use 6 (or 4))
% numBins:      Spatial binning of descriptors (e.g. SIFT is 4x4).

function [desc info] = Image2ColourNamePatches(cfext, imrgb, numPixels, numBins)

    % Use cell array for easy storage per scale
    descT = cell(1,5);
    infoT = cell(1,5);

    % Extract local descriptors on scale of the whole image
    [descr inf] = cfext.Image2DenseColourNamePatches(imrgb, numPixels);

    % This glues individual bins together
    [descT{1} infoT{1}] = cfext.Feature2Spatial(descr, inf, numBins);

    % The other 4 scales. Each time resize the image such that half of the pixels remain
    coorFac = 1;        
    for idx = 2:5 
        imrgb = imresize(imrgb, sqrt(.5), 'bilinear');
        coorFac = coorFac / sqrt(.5);
        [descr inf] = cfext.Image2DenseColourNamePatches(imrgb, numPixels);
        [descT{idx} infoT{idx}] = cfext.Feature2Spatial(descr, inf, numBins);

        infoT{idx}.row = round(infoT{idx}.row * coorFac);
        infoT{idx}.col = round(infoT{idx}.col * coorFac);
    end

    % Concatenate results for all scales.
    desc = cat(1, descT{:});
    info = cfext.ConcatenateInfo(infoT);

    % Normalize. Note that this way of normalization results in vectors with
    % unit length. When using the euclidean distance some other more
    % appropriate distance is used on the the original features. Details can be
    % found in "Three things everyone should know to improve object retrieval",
    % CVPR 2012
    desc = sqrt(cfext.NormalizeRows(desc));

end
