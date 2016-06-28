function populateFromString(obj)
%
%   http://www.unc.edu/~rowlett/units/
%
%   Called from constructor:
%   sl.units.unit_entry
%
%   Code moved here to reduce indentation and scrolling

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

temp = sl.units.defs.base_si_unit.createIfMatching(remaining_string);

if ~isempty(temp)
    return
end

temp = sl.units.defs.derived_si_unit.createIfMatching(remaining_string);

end

function parseTime()

%Time
%-----------------------------
    


keyboard


end