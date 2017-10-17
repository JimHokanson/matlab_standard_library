function output = split(str,varargin)
%
%   output = sl.str.split(str,varargin)
%
%   Optional Inputs
%   ---------------
%   d :
%   escape_d :

in.d = ',';
in.escape_d = false;
in = sl.in.processVarargin(in,varargin);

if in.escape_d
    error('Option not yet implemented')
end

output = regexp(str,in.d,'split');



end