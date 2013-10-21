function [features info] = Image2DenseColourNamePatches(cfext,im, nP)
    % [features info normalizationFactor] = Image2UDColourNamePatches(im, nP, elem)
    %
    % Function for extracting colour-name histograms per patch according to
    %   Van de Weijer, TIP 2011, color naming
    % Sampled at each nP-th pixel
    %
    % im:           RGB-image (double)
    % nP:           Size of subregions for patch
    % elem:         Spatiality of feature. Usual is 4 (as in SIFT)
    %
    % features:     N x (11 x elem^2) matrix with (subregion) features.
    % info:         info structure containing:
    %       n:      number of features in row direction
    %       m:      number of features in col direction
    %       row:    row coordinate per feature
    %       col:    col coordinate per feature

    % Make the image of the correct size
    [nR nC nZ] = size(im);
    imSize = [nR nC];
    newR = nR - mod(nR, nP);
    newC = nC - mod(nC, nP);
    im = im(1:newR, 1:newC,:);

    % Create 11-word image
    colourNameIm = cfext.Rgb2ElevenColourNames(im, true);

    % Now do summation over subregions for each pixel.
    subVec = ([1:nP nP:-1:1] - 0.5) ./ nP;
    for i=1:size(colourNameIm, 3)
        colourNameIm(:,:,i) = conv2(subVec, subVec', colourNameIm(:,:,i), 'same');
    end

    % Sum over the nP x nP subregions
    n = newR / nP;
    m = newC / nP;
    features = zeros(n,m,size(colourNameIm,3));
    arrayA = cfext.DiagMatrixLinear(n, newR);
    arrayB = cfext.DiagMatrixLinear(newC, m);

    for i=1:size(colourNameIm,3)
        features(:,:,i) = arrayA * colourNameIm(:,:,i) * arrayB;
    end

    features = reshape(features, [], size(colourNameIm,3));

    % Create info structure
    info = cfext.GetDenseInfoStructure(imSize, n, m, nP);

end
