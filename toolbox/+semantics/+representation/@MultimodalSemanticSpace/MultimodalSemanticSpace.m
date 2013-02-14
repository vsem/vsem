classdef MultimodalSemanticSpace < semantics.representation.GenericSemanticSpace
    %MULTIMODALSEMANTICSPACE Multimodal semantic space for distributional semantics modeling
    
    
    properties
        textVectors
        imageVectors
        %conceptsAndVectors
    end
    
    methods
        % overrides the superclass constructor
        function obj = MultimodalSemanticSpace(concepts, textVectors, imageVectors)
            % class constructor
            if(nargin > 0)
                obj.concepts = concepts ;
                obj.textVectors = textVectors ;
                obj.imageVectors = imageVectors ;
                obj.concept2vector = obj.mapConcept2Vector(concepts) ;
            end
        end
        function dim = getConceptsDim(obj)
            dim = size(obj.codebook_,2);
        end
        
        % Compute the similarity between two target concepts in the semantic space.
        % You need to specify also the channel ('text' or 'image').
        % If one of the two concepts to be compared is not found, it returns -1.
        function similarityScore = getSimilarity(obj, concept1, concept2, similarityMeasure, channel)
            
            if obj.concept2vector.isKey(concept1) == 1 && obj.concept2vector.isKey(concept2) == 1
                switch lower(channel)
                    case 'text'
                        textVector1 = obj.textVectors(obj.concept2vector(concept1),:) ;
                        textVector2 = obj.textVectors(obj.concept2vector(concept2),:) ;
                        similarityScore = 1 - pdist2(textVector1, textVector2, similarityMeasure) ;
                    case 'image'
                        imageVector1 = obj.imageVectors(obj.concept2vector(concept1),:) ;
                        imageVector2 = obj.imageVectors(obj.concept2vector(concept2),:) ;
                        similarityScore = 1 - pdist2(imageVector1, imageVector2, similarityMeasure) ;
                end
            else
                similarityScore = -1 ;
            end
        end
        
        % Compute the weighted similarity between two target concepts in the semantic space.
        % You need to specify also the channel ('text' or 'image'), the
        % weight mode and the weights.
        % If one of the two concepts to be compared is not found, it returns -1.
        function weightedSimilarityScore = getWeightedSimilarity(obj, concept1, concept2, similarityMeasure, channel, weightingMode, conceptWeights)
            
            if obj.concept2vector.isKey(concept1) == 1 && obj.concept2vector.isKey(concept2) == 1
                weight = 0 ;
                switch lower(weightingMode)
                    case 'mean'
                        weight = mean(conceptWeights) ;
                    case 'min'
                        weight = min(conceptWeights) ;
                    case 'max'
                        weight = max(conceptWeights) ;
                end
                
                switch lower(channel)
                    case 'text'
                        textVector1 = obj.textVectors(obj.concept2vector(concept1),:) ;
                        textVector2 = obj.textVectors(obj.concept2vector(concept2),:) ;
                        similarityScore = 1 - pdist2(textVector1, textVector2, similarityMeasure) ;
                        % the similarity score is weighted
                        weightedSimilarityScore = similarityScore .* weight ;
                    case 'image'
                        imageVector1 = obj.imageVectors(obj.concept2vector(concept1),:) ;
                        imageVector2 = obj.imageVectors(obj.concept2vector(concept2),:) ;
                        similarityScore = 1 - pdist2(imageVector1, imageVector2, similarityMeasure) ;
                        % the similarity score is weighted
                        weightedSimilarityScore = similarityScore .* weight ;
                end
            else
                weightedSimilarityScore = -1 ;
            end
        end
        
        function reweightedVector = reweightVector(vector, weight)
            normalizedVector = vector/norm(vector) ;
            reweightedVector = (normalizedVector .* weight) ;
        end
    end
    
    
end





