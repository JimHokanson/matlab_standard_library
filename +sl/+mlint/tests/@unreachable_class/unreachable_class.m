classdef unreachable_class
    %
    %
    %   This is for testing mlint code
    
    properties
        test = {'asdf'
            'cheese'
            'burger'
            @sl.in.processVarargin}
        %This is a test of the emergency broadcast system
        
        test2 = {... %Testing the gap (...) on the next line
            ...
            'does this work'}
        %Hi mom!
        
        test3 %3rd test is the best test
        %@units:mV
        %@display:cheese
        
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