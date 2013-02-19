classdef MultimodalSemanticSpace < semantics.representation.GenericSemanticSpace
% MULTIMODALSEMANTICSPACE Represents a multimodal distributional semantics model
%   MULTIMODALSEMANTICSPACE = MULTIMODALSEMANTICSPACE(CONCEPTS, TEXTVECTORS, IMAGEVECTORS) 
%   returns an instance of the the class MULTIMODALSEMANTICSPACE(). 
%   The constructor calls also
%   the method mapConcept2Vector of the superclass GENERICSEMANTICSPACE() which
%   assign indexes to concept and store them into a hastable (see
%   GenericSemanticSpace for more details).
%
%
%   PROPERTIES
%
%   > Inherited
%
%   concepts::
%     The concepts represented by the multimodal semantic space.
%
%   concept2vector::
%     A mapping form concepts to vectors.
%
%   > Class specific
%
%   textVectors::
%     The text-based vector representation of the concepts.
%
%   imageVectors::
%     The image-based vector representation of the concepts.
%
%
%   CONSTRUCTORS
%
%   > Class specific
%
%   obj = MultimodalSemanticSpace(concepts, textVectors, imageVectors)::
%      Returns an instance of this class.
%
%      [Arguments] 
%
%      concepts:      the concepts represented by the multimodal semantic space
%
%      textVectors:   the text-based vector representation of the concepts  
%
%      imageVectors:  the image-based vector representation of the concepts
%
%   METHODS
%
%   > Inherited
%
%   concept2vector = mapConcept2Vector(concepts)::
%     Static. Map concepts to their vectors and it is automatically called 
%     by the constructor of this class. Importantly, it assumes the
%     concepts being in sorted order. 
%
%   > Class specific
%
%   similarityScore = getSimilarity(obj, concept1, concept2, similarityMeasure, channel)::
%      Returns the semantic similarity score between two concepts. If one 
%      of the two concepts to be compared is not found, it returns -1. 
%  
%      [Arguments] 
%
%      concept1, concept2:  the two target concepts
%
%      similarityMeasure:   the similarity measure (see help PDIST2 for the full list of measures)
%
%      channel:             the channel to use for computing the similarity score, it can be 'text' or 'image'
%
%   weightedSimilarityScore = getWeightedSimilarity(obj, concept1, concept2, similarityMeasure, channel, conceptWeights, weightingMode)::
%      Returns the weighted similarity score between two concepts. If one 
%      of the two concepts to be compared is not found, it returns -1.
%
%      [Arguments] 
%
%      concept1, concept2:  the two target concepts
%
%      similarityMeasure:   the similarity measure (see help PDIST2 for the full list of measures)
%
%      channel:             the channel to use for computing the similarity score, it can be 'text' or 'image'
%
%      conceptWeights:      the weights for the two concepts
%
%      weightingMode:       it specifies the way to mix the two concept weights; it can be 'mean', 'min' or 'max'
%
% Authors: A1

% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).
    
    
    properties
        textVectors
        imageVectors
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
        

        function weightedSimilarityScore = getWeightedSimilarity(obj, concept1, concept2, similarityMeasure, channel, conceptWeights, weightingMode)
            
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





