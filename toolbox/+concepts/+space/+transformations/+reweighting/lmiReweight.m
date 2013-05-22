function lmiM = lmiReweight(M)
    lmiM = double(M) .* concepts.space.transformations.reweighting.pmiReweight(M);
end