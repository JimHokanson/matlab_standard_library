function match_base_unit(obj,str)
%
%   - change name to getBaseUnitInfo

length	meter	m
mass	kilogram      	kg
time	second	s
electric current	ampere	A
thermodynamic temperature      	kelvin	K
amount of substance	mole	mol
luminous intensity	candela	cd


%mass
switch str
    case {'g' 'gram'}
        obj.short = 'g';
        obj.long  = 'gram';
        obj.is_si = true;
        obj.type  = 'mass';
        obj.to_si = 1;
    case {'m' 'meter'}
        obj.short = 'm';
        obj.long = 'meter';
        obj.is_si = true;
        obj.type = 'length';
        obj.to_si = 1;
    case {'s' 'second'}
        obj.short = 's';
        obj.long = 'second';
        obj.is_si = true;
        obj.type = 'time';
        obj.to_si = 1;
    case {'A' 'ampere'}
    case {'K' 'kelvin'}
    case {'mol' 'mole'}
    case {'cd' 'candela'}
end

end


