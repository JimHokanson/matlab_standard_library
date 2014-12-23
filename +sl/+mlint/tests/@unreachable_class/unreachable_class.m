classdef unreachable_class
    %
    %
    %   This is for testing mlint code
    
    properties
    end
    
    methods
        function obj = unreachable_class()
            testing(1)
            function testing(x)
               disp(x) 
            end
        end
    end
    
end

function h__ExtraFunction()

end