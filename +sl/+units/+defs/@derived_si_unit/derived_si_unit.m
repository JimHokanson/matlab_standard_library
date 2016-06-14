classdef derived_si_unit
    %
    %   Class:
    %   si.units.defs.derived_si_unit
    
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
       raw
       short
       long
       in_base_units
    end
    
    methods (Static)
        function createIfMatching(str)
           obj_or_null = h__match_SI_unit(str); 
        end
    end
    
end

function obj = h__match_SI_unit(str)
%
%   - change name to getBaseUnitInfo

obj = sl.units.defs.derived_si_unit();

obj.raw = str;

%mass
switch str
    case {'Hz' 'hertz'}
        obj.short = 'Hz';
        obj.long  = 'hertz';
        obj.quantity_type  = 'frequency';
        obj.in_base_units = {'s' -1};
    case {'N' 'newton'}
        obj.short = 'N';
        obj.long = 'newton';
        obj.quantity_type = 'force';
        obj.in_base_units = {'m' 1 'kg' 1 's' -2};
    case {'Pa' 'pascal'}
        obj.short = 'Pa';
        obj.long = 'pascal';
        obj.quantity_type = 'pressure, stress';
    %TODO: finish - http://physics.nist.gov/cuu/Units/units.html
end

if isempty(obj.quantity_type)
    obj = [];
end

end