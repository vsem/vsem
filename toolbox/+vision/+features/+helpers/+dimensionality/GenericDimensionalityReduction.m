classdef GenericDimensionalityReduction < handle
    %GenericDimensionalityReduction Generic interface for dimensionality reduction
    
    properties
        featureExtractor
    end
    
    methods(Abstract)
        low_proj = train(obj)
    end
    
end

