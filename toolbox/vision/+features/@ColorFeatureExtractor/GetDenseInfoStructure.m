function info = GetDenseInfoStructure(cfext,imSize, n, m, regionSize, offset)
    % info = GetDenseInfoStructure(imSize, regionSize)
    %
    % Gets the info structure for Dense Features.
    %
    % imSize:       size of the image
    % n:            number of subregions in row direction
    % m:            number of subregions in col direction
    % regionSize:   size of subregion in pixels
    % offset:       offset of image
    %
    % info:         info structure used for a.o. making feature spatial
    %   n:          number of subregions in row direction
    %   m:          number of subregions in col direction
    %   row:        row coordinate per feature
    %   col:        col coordinate per feature
    %   imSize:     size of image where features are extracted.
    %   regionSize: size of region

    if nargin < 5
        regionSize = floor(imsize(1) / n);
    end

    if nargin < 6
        offset = [0 0];
    end

    info.imSize = imSize;

    info.n = n;
    info.m = m;
    info.regionSize = regionSize;

    % Coordinates
    info.row = (1:info.n) * regionSize - ((regionSize-1)/2);
    info.row = repmat(info.row, 1, info.m);
    info.row = info.row(:) + offset(1);

    info.col = (1:info.m) * regionSize - ((regionSize-1)/2);
    info.col = repmat(info.col, info.n, 1);
    info.col = info.col(:) + offset(2);

end
