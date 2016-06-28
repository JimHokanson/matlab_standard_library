classdef unit
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
        base_name
        power %x
        in_numerator
        
        is_si
        type 
        %   - distance
        %   - time
        %   - unitless
        prefix
        
        
        display_str %how the string is displayed
        %this will keep user naming
        %
        %Let's convert powers of -1 so that raw and display string could
        %be different
        short
        long
        base_power
    end
    
    methods
        function obj = unit(raw,in_numerator)
           obj.raw = strtrim(raw);
           obj.in_numerator = in_numerator;
           obj.populateFromString();
           %TODO: Parse details
           
           raw = obj.raw;

            temp = regexp(raw,'\^','split');

            if length(temp) > 2
                error('Expecting only a value (e.g. kg) or value with exponent (kg^2)')
            end

            root_string = temp{1};
            if length(temp) == 2
                obj.power = str2double(temp{2});
                if obj.power < 0
                   obj.power = -obj.power;
                   obj.in_numerator = ~obj.in_numerator;
                end
            else
                obj.power = 1;
            end

            if strcmp(raw,'1')
               obj.type = 'unitless';
               return
            end

            [obj.prefix,remaining_string] = sl.units.prefix.fromUnitString(root_string);
            
            obj.base_name = remaining_string;
            
            if obj.power == 1
                obj.display_str = obj.base_name;
            else
                obj.display_str = sprintf('%s^%0g',obj.base_name,obj.power);
            end
            
            keyboard
           
           
        end
    end
    
end

