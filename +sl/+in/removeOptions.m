function [removed_options,remaining_options] = removeOptions(varargin_data,names_to_remove,varargin)
%x Removes a set of option names (and values) so that all names are valid
%
%   ******* CONSIDER USING sl.in.splitAndProcessVarargin INSTEAD *********
%   
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
%       If true, the outputs will be a cell. This is equivalent to
%           output_types = {'cell' 'cell'}
%   force_struct : false
%       If true, the outputs will be a struct. This is equivalent to
%           output_types = {'struct' 'struct'}
%   output_types : cellstr, (default not used)
%       Options include:
%       {'cell' 'cell'}
%       {'struct' 'struct'}
%       {'cell' 'struct'}
%       {'struct' 'cell'}
%       
%   
%
%   Examples:
%   ---------
%   1) Process some inputs and leave the rest for going into the line
%   function
%
%    in.I = 'all';
%    in.axes = 'gca';
%    %This line takes out 'I' and 'axes' prop/value pairs if present
%    [varargin,line_inputs] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
%    in = sl.in.processVarargin(in,varargin);
%    ...
%    line(x,y,line_inputs{:})
%
%
%   The default behavior is to keep the same kind of output as the input

in.output_types = {};
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

%Both values are cells at this point ...
if ~isempty(in.output_types)
    if in.output_types{1}(1) == 's'
       removed_options = sl.in.propValuePairsToStruct(removed_options); 
    end
    if in.output_types{2}(1) == 's'
       remaining_options = sl.in.propValuePairsToStruct(remaining_options);  
    end
elseif in.force_struct
   removed_options = sl.in.propValuePairsToStruct(removed_options);
   remaining_options = sl.in.propValuePairsToStruct(remaining_options); 
elseif in.force_cell
    %do nothing, both are cells
    %This takes precedence over was_struct
elseif was_struct
   removed_options = sl.in.propValuePairsToStruct(removed_options);
   remaining_options = sl.in.propValuePairsToStruct(remaining_options);     
end


end