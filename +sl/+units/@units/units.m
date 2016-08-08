classdef units
    %
    %   Class:
    %   sl.units.units
    %
    %   Tasks
    %   -----
    %   1) Load unit from string
    %   2) Convert from one units to another
    %   3) Simplify units
    
    %{
    1) 

    str = 'kg/ms';
    temp = sl.units.units(str);
    
    
    %}
    
    properties
       parts %unit
    end
    
    methods
        function obj = units(input_string)
            obj.parts = h__getParts(input_string, true, false);
        end
        function convertTo(new_string_or_units)
           %TODO: Implement this ...
           %merge specs 
        end
    end
    
end

function string_parts = h__getParts(cur_str, in_numerator,in_parens)

u = @sl.units.unit;

string_parts = cell(1,10);
cur_part = 0;
in_part = false;
start_I = 0;
iStr = 1;
while (iStr <= length(cur_str))
    
    switch cur_str(iStr)
        case '('
            if in_parens
                error('Nested parens not yet handled')
            end
            
            %get everything until the end of the parens
            I = find(cur_str(iStr+1:end) == ')',1);
            if isempty(I)
                error('Unmatched parens')
            end
            %TODO: Check that we aren't empty
            
            %recursive call
            temp = h__getParts(cur_str(iStr+1:iStr+I-1),in_numerator,true);
            string_parts(cur_part+1:cur_part+length(temp)) = temp;
            cur_part = cur_part + length(temp);
            iStr = iStr + I + 1;
            %Parse the bits inbetween
        case ')'
            error('Unmatched parens')
        case '/'
            if cur_part == 0
                error('error, units can''t start with /')
            end
            
            if in_part
                temp_string = cur_str(start_I:iStr-1);
                string_parts{cur_part} = u(temp_string,in_numerator);
                in_part = false;
            end
            
            in_numerator = false;
        case '*'
            if cur_part == 0
                error('error, units can''t start with *')
            end
            
            if in_part
                temp_string = cur_str(start_I:iStr-1);
                string_parts{cur_part} = u(temp_string,in_numerator);
                in_part = false;
                if ~in_parens
                    in_numerator = true;
                end %else - stay the same (
            end
            
        otherwise
            if ~in_part
                cur_part = cur_part + 1;
                start_I = iStr;
                in_part = true;
            end
    end
    iStr = iStr + 1;
end

if in_part
    temp_string = cur_str(start_I:iStr-1);
    string_parts{cur_part} = u(temp_string,in_numerator);
end

string_parts(cur_part+1:end) = [];
end