classdef unit < handle
    %
    %   Class:
    %   sl.units.unit
    %
    %   An individual unit element (with exponent)
    
    %{

        temp = sl.units.unit('kg^2',true);

    %}
    
    properties
        raw %raw string input to the class
        in_numerator
        power
        prefix
        spec %TODO: Define abstract class
        
%         is_si
%         type
%         %   - distance
%         %   - time
%         %   - unitless
%         prefix
%         
%         
%         display_str %how the string is displayed
%         %this will keep user naming
%         %
%         %Let's convert powers of -1 so that raw and display string could
%         %be different
%         short
%         long
%         base_power
    end
    
    methods
        function obj = unit(raw,in_numerator)
            obj.raw = strtrim(raw);
            obj.in_numerator = in_numerator;
            obj.populateFromString();
                        
        end
    end
    
end

