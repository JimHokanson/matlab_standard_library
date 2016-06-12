classdef prefix
    %
    %   Class:
    %   sl.units.prefix
    %
    %   See Also:
    %   sl.units.prefixes
    
    properties
        string
        power
        is_short %Whether the prefix is the long or short version
        %
        %To switch we should build a method in prefixes that supports
        %switching
    end
    
    methods
        function obj = prefix(string,power,is_short)
            %
            %   obj = sl.units.prefix(short,long,power,is_short)
            obj.string = string;
            obj.power = power;
            obj.is_short = is_short;
        end
        function remaining_string = removePrefixFromString(obj,input_string)
            %TODO: Verify that the input does in fact match the string
            start_I = length(obj.string) + 1;
            
            remaining_string = input_string(start_I:end);
        end
    end
    
    methods (Static)
        function [obj,remaining_string] = fromUnitString(unit_string)
            %
            %   [obj,remaining_string] = sl.units.prefix.fromUnitString(unit_string)
            %
            
            prefixes = sl.units.prefixes.getInstance();
            obj = prefixes.getPrefixMatch(unit_string);
            if isempty(obj)
                remaining_string = '';
            else
                remaining_string = obj.removePrefixFromString(unit_string);
            end
        end
    end
    
end

