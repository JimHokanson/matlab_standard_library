function [removed_options,remaining_options] = removeOptions(varargin_data,names_to_remove,varargin)
%x Removes a set of option names (and values) so that all names are valid
%
%   [removed_options,remaining_options] = sl.in.removeOptions(varargin_data,names_to_remove)
%
%   This was designed to facilitate passing options into a parent function
%   that subsequently get passed into multiple children function where the
%   option names change between the children.
%
%   TODO: promote the options to a class which can handle this conflict
%   so that no structure editing is needed - work started as
%   sl.in.optional_inputs
%
%   Optional Inputs:
%   ----------------
%   force_cell : false
%       If true, the output will be a cell
%   force_struct : false
%       If true, the output will be a struct
%
%   The default behavior is to keep the same kind of output as the input

in.force_cell = false;
in.force_struct = false;
in = sl.in.processVarargin(in,varargin);

if isstruct(varargin_data)
    was_struct = true;
    varargin_data = sl.in.structToPropValuePairs(varargin_data);
else
    was_struct = false;
end

removed_options = {};
remaining_options = varargin_data;

for iName = 1:length(names_to_remove)
    cur_name = names_to_remove{iName};
    I = find(strcmp(cur_name,remaining_options(1:2:end)),1);
    if ~isempty(I)
       I2 = 2*I;
       I1 = I2 - 1;
       removed_options{end+1} = cur_name; %#ok<AGROW>
       removed_options(end+1) = remaining_options(I2); %#ok<AGROW>
       remaining_options([I1 I2]) = [];
    end
end

if in.force_cell
    return
end

if in.force_struct || was_struct
   removed_options = sl.in.propValuePairsToStruct(removed_options);
   remaining_options = sl.in.propValuePairsToStruct(remaining_options); 
end


end