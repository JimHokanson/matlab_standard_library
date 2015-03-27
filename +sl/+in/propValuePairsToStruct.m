function struct_output = propValuePairsToStruct(cell_input,varargin)
%
%   struct_output = sl.in.propValuePairsToStruct(cell_input,varargin)
%
%   TODO: Finish documentation

in.force_lower = false;
in.force_upper = false;
in = sl.in.processVarargin(in,varargin);

v = cell_input(:)'; %Ensure row vector
if in.force_lower
    fh = @lower;
elseif in.force_upper
    fh = @upper;
else
    fh = @(x)x;
end
struct_output = cell2struct(v(2:2:end),fh(v(1:2:end)),2);


end