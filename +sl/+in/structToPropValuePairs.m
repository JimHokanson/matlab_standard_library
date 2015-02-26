function cell_output = structToPropValuePairs(option_struct)
%x Convert from a structure to a cell with property/value pairs
%   
%   cell_output = sl.in.structToPropValuePairs(option_struct)
%
%   Converts from a structure with fields to a cell that has each field
%   name followed by its value.
%
%   TODO: Add on an example


fn = fieldnames(option_struct);
values = struct2cell(option_struct);

cell_output = cell(1,length(fn)*2);

cell_output(1:2:end) = fn;
cell_output(2:2:end) = values;

end