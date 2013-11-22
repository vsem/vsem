function matrix = lmiReweight(matrix)
    matrix = double(matrix) .* pmiReweight(matrix);
end