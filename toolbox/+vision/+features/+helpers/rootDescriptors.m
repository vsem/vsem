function rootD = rootDescriptors(D)
    %ROOTD Normalizes and takes the root of descriptors.
    %
    % rootDesciptors(D)
    %
    % Normalizes and takes the root of descriptors (columns of D).

    rootD = sqrt(vision.features.helpers.normalizeColumns(D));
