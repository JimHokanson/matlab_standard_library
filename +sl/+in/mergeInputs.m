function output_values = mergeInputs(starting_values,new_values,varargin)
%
%   output_values = sl.in.mergeInputs(starting_values,new_values)
%
%   This allows merging of optional inputs with default inputs. It was
%   originally written for combining default plotting options with user
%   inputs that might overwrite the default options.
%
%   Inputs:
%   -------
%   starting_values : cell or struct
%       These are the base set of values that will be overwritten with any
%       conflicting property names from 'new_values'
%   new_values : cell or struct
%
%   Optional Inputs:
%   ----------------
%   case_sensitive : logical (default false)
%       If false, then all output prop names will have their case changed
%       to lowercase which will force collisions with differently cased
%       property names (see Example 1)
%
%   Example:
%   --------
%   1) 
%   output_values = sl.in.mergeInputs({'Linewidth',2,'Color','k'},{'linewidth',3})
%   output_values => {'linewidth'    [3]    'color'    'k'}

in.case_sensitive = false;
in = sl.in.processVarargin(in,varargin);

start_was_cell = iscell(starting_values);
if iscell(starting_values)
    starting_values = sl.in.propValuePairsToStruct(starting_values);
end
if iscell(new_values)
    new_values = sl.in.propValuePairsToStruct(new_values);
end

if ~in.case_sensitive
   starting_values = h__fixFieldNames(starting_values);
   new_values = h__fixFieldNames(new_values);
end

fn = fieldnames(new_values);

output_values = starting_values;

for iName = 1:length(fn)
    cur_name = fn{iName};
    output_values.(cur_name) = new_values.(cur_name);
end

if start_was_cell
    output_values = sl.in.structToPropValuePairs(output_values);
end

end

function s_out = h__fixFieldNames(s)

fn = fieldnames(s);

s_out = struct;

for iName = 1:length(fn)
    cur_name = fn{iName};
    s_out.(lower(cur_name)) = s.(cur_name);
end


end