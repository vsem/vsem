classdef SemanticSpace < semantics.representation.GenericSemanticSpace
    %SEMANTICSPACE Semantic space for distributional semantics modeling
    
    
    properties
        vectors
        
    end
    
    
    methods
        % overrides the superclass constructor
        function obj = SemanticSpace(concepts, vectors)
            % class constructor
            if(nargin > 0)
                obj.concepts = concepts ;
                obj.vectors   = vectors ;
                obj.concept2vector = mapConcept2Vector(concepts) ;
                
            end
        end
        
        % Computes the similarity between two target concepts in the semantic space.
        % If one of the two concepts to be compared is not found, it returns 0.
        function similarityScore = getSimilarity(obj, concept1, concept2, similarityMeasure)
            if obj.concept2vector.isKey(concept1) == 1 && obj.concept2vector.isKey(concept2) == 1
                vector1 = obj.vectors(obj.concept2vector(concept1)) ;
                vector2 = obj.vectors(obj.concept2vector(concept2)) ;
                similarityScore = 1 - pdist2(vector1, vector2, similarityMeasure) ;
            else
                similarityScore = 0 ;
            end
        end
    end
    
end

