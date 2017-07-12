function output = startsWith(cellstr,string,varargin)
%
%   mask = sl.cellstr.startsWith(cellstr,string,varargin)
%
%   object = sl.cellstr.startsWith(cellstr,string,'as_object',true,varargin)
%
%   Optional Inputs
%   ---------------
%   case_sensitive : default false
%   as_object : default false
%       If true, returns instance of:
%           sl.cellstr.results.starts_with
%
%   See Also
%   --------
%   sl.cellstr.results.starts_with

in.case_sensitive = false;
in.as_object = false;
in = sl.in.processVarargin(in,varargin);

if in.case_sensitive
    fh = @strncmp;
else
    fh = @strncmpi;
end

mask = fh(cellstr,string,length(string));

if in.as_object
    output = sl.cellstr.results.starts_with(cellstr,string,mask);
else
    output = mask;
end

end