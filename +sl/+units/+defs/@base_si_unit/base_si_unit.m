classdef base_si_unit < handle
    %
    %   Class:
    %   sl.units.defs.base_si_unit
    %
    %   sl.units.defs.base_si_unit.createIfMatching
    
    %{
        temp = sl.units.defs.base_si_unit.createIfMatching('g')
    %}
    
    properties
       %Common - TODO: make abstract 
       unit_type = 'si'
       quantity_type
       %    1) mol  amount_of_substance
       %    2) A    electric
       %    3) m    length
       %    4) cd   luminous_intensity
       %    5) g    mass
       %    6) K    thermodynamic_temperature
       %    7) s    time
       raw  %is_short instead?????
       short
       long
       quantity_array %1 x 7
    end
    
    
    methods (Static)
        function obj_or_null = createIfMatching(str)
           obj_or_null = h__match_SI_unit(str); 
        end
    end
    
end

%Made a helper function just to reduce indentation
function obj = h__match_SI_unit(str)
%
%   - change name to getBaseUnitInfo

obj = sl.units.defs.base_si_unit();

obj.raw = str;

obj.quantity_array = zeros(1,7);
%mass
switch str
    case {'g' 'gram'}
        obj.short = 'g';
        obj.long  = 'gram';
        obj.quantity_type  = 'mass';
        qa = 5;
    case {'m' 'meter'}
        obj.short = 'm';
        obj.long = 'meter';
        obj.quantity_type = 'length';
        qa = 3;
    case {'s' 'second'}
        obj.short = 's';
        obj.long = 'second';
        obj.quantity_type = 'time';
        qa = 7;
    case {'A' 'ampere'}
        obj.short = 'A';
        obj.long = 'ampere';
        obj.quantity_type = 'electric';
        qa = 2;
    case {'K' 'kelvin'}
        obj.short = 'K';
        obj.long = 'kelvin';
        obj.quantity_type = 'thermodynamic_temperature';
        qa = 6;
    case {'mol' 'mole'}
        obj.short = 'mol';
        obj.long  = 'mole';
        obj.quantity_type = 'amount_of_substance';
        qa = 1;
    case {'cd' 'candela'}
        obj.short = 'cd';
        obj.long = 'candela';
        obj.quantity_type = 'luminous_intensity';
        qa = 4;
end



if isempty(obj.quantity_type)
    obj = [];
else
    obj.quantity_array(qa) = 1;
end

end
