classdef value < double
    %
    %   Class:
    %   sl.units.value
    
    properties (Hidden)
       display_string
    end
    
    methods
        function obj = value(input_value,units_string)
           obj.display_string = units_string;
        end
    end
    
end

