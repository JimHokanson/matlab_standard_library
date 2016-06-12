classdef unit_entry
    %
    %   Class:
    %   sl.units.unit_entry
    
    properties
        raw
        type 
        %   - distance
        %   - time
        %   - unitless
        prefix
        base_name
        display_str %how the string is displayed
        %this will keep user naming
        %
        %Let's convert powers of -1 so that raw and display string could
        %be different
        power
        in_numerator
    end
    
    methods
        function obj = unit_entry(raw,in_numerator)
           obj.raw = strtrim(raw);
           obj.in_numerator = in_numerator;
           obj.populateFromString();
           %TODO: Parse details
        end
    end
    
end

