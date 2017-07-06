function mask = startsWith(cellstr,string,varargin)
%
%   mask = sl.cellstr.startsWith(cellstr,string,varargin)

in.case_sensitive = false;
in = sl.in.processVarargin(in,varargin);

if in.case_sensitive
    fh = @strncmp;
else
    fh = @strncmpi;
end

mask = fh(cellstr,string,length(string));

end