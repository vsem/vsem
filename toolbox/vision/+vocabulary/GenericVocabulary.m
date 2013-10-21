classdef GenericVocabulary < handle
    %GENERICCODEBKGEN Generic interface for training visual vocabularies
    
    properties
    end
    
    methods(Abstract)
        vocabulary = trainVocabulary(obj)
    end
    
end

