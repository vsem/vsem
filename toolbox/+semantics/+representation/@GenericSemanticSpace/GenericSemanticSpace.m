classdef GenericSemanticSpace
    %GENERICSEMANTICSPACE Generic interface for representing semantic
    %information
    
    properties
        concepts % the only property we consider completely general
        concept2vector % containers.Map, maps concepts to their vectors
        
    end
    
    methods(Static)
        % assign indexes to concepts and store them into a hastable
        function concept2vector = mapConcept2Vector(concepts)
            concept2vector = containers.Map();  % create container
            for index = 1:numel(concepts)      % loop over concepts to add
                concept = concepts{index} ;
                if concept2vector.isKey(concept)
                    error('SemanticsError:multipleKey', 'Concepts must be unique, your list has a duplicate!')
                else
                    concept2vector(concept) = index;  % make a new key
                end
            end
        end
    end
    
    
end

