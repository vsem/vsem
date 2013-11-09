function [imagePaths, annotations, conceptList] = randomDatasetSubset(n, imagePaths, annotations)
    ids = vl_colsubset(1:length(imagePaths), n);
    imagePaths = imagePaths(ids);
    annotations = annotations(ids);
