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
       %- length
       %- mass
       %- time
       %- electric
       %- thermodynamic_temperature
       %- amount_of_substance
       %- luminous_intensity
       raw  %is_short instead?????
       short
       long
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

%mass
switch str
    case {'g' 'gram'}
        obj.short = 'g';
        obj.long  = 'gram';
        obj.quantity_type  = 'mass';
    case {'m' 'meter'}
        obj.short = 'm';
        obj.long = 'meter';
        obj.quantity_type = 'length';
    case {'s' 'second'}
        obj.short = 's';
        obj.long = 'second';
        obj.quantity_type = 'time';
    case {'A' 'ampere'}
        obj.short = 'A';
        obj.long = 'ampere';
        obj.quantity_type = 'electric';
    case {'K' 'kelvin'}
        obj.short = 'K';
        obj.long = 'kelvin';
        obj.quantity_type = 'thermodynamic_temperature';
    case {'mol' 'mole'}
        obj.short = 'mol';
        obj.long  = 'mole';
        obj.quantity_type = 'amount_of_substance';
    case {'cd' 'candela'}
        obj.short = 'cd';
        obj.long = 'candela';
        obj.quantity_type = 'luminous_intensity';
end

if isempty(obj.quantity_type)
    obj = [];
end

end
