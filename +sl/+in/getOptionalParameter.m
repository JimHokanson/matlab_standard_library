function [is_found,value,options] = getOptionalParameter(options,name,varargin)
%
%   [is_found,value,options] = sl.in.getOptionalParameter(options,name,varargin)
%
%   I originally wrote this in the case in which I needed to do something
%   specific if a 'Parent' optional input had been passed into a function.
%
%   Inputs
%   ------
%   options : struct or cell
%       Contains property/value pairs
%   name : string
%       Name of the property whose value should be found
%
%   Optional Inputs
%   ---------------
%   default : (default [])
%       Default value if not found. Using this can avoid an if statement
%       in the caller.
%   remove : (default false)
%       If true, the value is removed if found.
%
%   Outputs
%   -------
%   is_found : logical
%       Whether or not the name was present in the options
%   value : 
%       The value of the specified property option.
%
%   Examples
%   --------
%   [is_found,value] = sl.in.getOptionalParameter(options,'parent')
%
%   [is_found,value,options] = sl.in.getOptionalParameter(options,'max_allowed','default',3,'remove',true)

in.default = [];
in.remove = false;
in = sl.in.processVarargin(in,varargin);

value = in.default;
if isstruct(name)
    is_found = isfield(options,name);
    if is_found
        value = options.(name);
    	if in.remove
            options = rmfield(options,name);
        end
    end
else

    %TODO: Does this behavior need to change???
    %Are multiple matches an error or is the last one typically used ...
    %
    %TODO: What about case sensitivity?????
    I = find(strcmpi(options(1:2:end),name),1);
    is_found = ~isempty(I);
    if is_found
       value = options{2*I};
        if in.remove
            options([2*I - 1, 2*I]) = [];
        end
    end

end