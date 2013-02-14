function [similarityScores pairWithScores]  = vsem_computeSimilarity(multimodalSemanticSpace, conceptPairs, similarityMeasure, channel, weightingModes, scores)
%
%
%
%
%
%
%
%

% -------------------------------------------------------------------
%
% -------------------------------------------------------------------


    for k = 1:numel(weightingModes)
        scoreIndex = 1 ;
        conceptPairScores = {} ;
        for i = 1:numel(conceptPairs(:,1))
            concept1 = conceptPairs{i,1} ;
            concept2 = conceptPairs{i,2} ;
            if scores.isKey(concept1) == 1 && scores.isKey(concept2) == 1
                concept1Score = (1 - scores(concept1))/2 ;
                concept2Score = (1 - scores(concept2))/2 ;
                if strcmp(channel, 'image')
                    concept1Score = 1 - concept1Score  ;
                    concept2Score = 1 - concept1Score ;                
                end
                conceptPairWithScore{scoreIndex} = {concept1 concept2} ;
                conceptPairScore = multimodalSemanticSpace.getWeightedSimilarity(concept1, concept2, similarityMeasure, channel, weightingModes{k}, [concept1Score concept2Score]) ;
            
                if conceptPairScore ~= -1
                    conceptPairScores{scoreIndex} = conceptPairScore ;
                    scoreIndex = scoreIndex+1 ;
                end
            end
        end
        similarityScores{k} = conceptPairScores ;
        pairWithScores{k} = conceptPairWithScore ;
    end












