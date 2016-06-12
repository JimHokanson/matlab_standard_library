function populateFromString(obj)
%
%   http://www.unc.edu/~rowlett/units/
%
%   Called from constructor:
%   sl.units.unit_entry

%{

   temp = sl.units.unit_entry('kg^2',true);

%}


raw = obj.raw;

temp = regexp(raw,'\^','split');

if length(temp) > 2
    error('Expecting only a value or value with exponent')
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
end

[obj.prefix,remaining_string] = sl.units.prefix.fromUnitString(root_string);

keyboard

end

function parseTime()

%Time
%-----------------------------
    


keyboard


end