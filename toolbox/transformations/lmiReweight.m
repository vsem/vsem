function matrix = lmiReweight(matrix)
    matrix = double(matrix) .* concepts.space.transformations.reweighting.pmiReweight(matrix);
end