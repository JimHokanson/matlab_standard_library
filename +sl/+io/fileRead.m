function out = fileRead(file_path,type,varargin)
%
%
%   out = sl.io.fileRead(file_path,type,varargin)
%
%   Similiar to fileread() except that it allows specification of a single
%   fread type, like uint8
%
%   Inputs
%   -----------------------------------------------------------------------
%   type   : passed directly into fread
%
%   Optional Inputs
%   -----------------------------------------------------------------------
%   endian : (default 'n')
%
%   example:
%   -------------------------------------------------------------
%   out = sl.io.fileRead(file_path,'*uint8')

in.endian = 'n';
in = sl.in.processVarargin(in,varargin);

% 'native'      or 'n' - local machine format - the default
% 'ieee-le'     or 'l' - IEEE floating point with little-endian
%                        byte ordering
% 'ieee-be'     or 'b' - IEEE floating point with big-endian
%                        byte ordering
% 'ieee-le.l64' or 'a' - IEEE floating point with little-endian
%                        byte ordering and 64 bit long data type
% 'ieee-be.l64' or 's' - IEEE floating point with big-endian byte
%                        ordering and 64 bit long data type.



%NOTE: I've run into problems with unicode ...
%
if ~exist(file_path,'file')
    error('Specified file does not exist:\n%s\n',file_path)
end

% open the file
[fid, msg] = fopen(file_path,'r',in.endian);
if fid == (-1)
    error(message('sl:io:fileRead:cannotOpenFile', filename, msg));
end

try
    % read file
    out = fread(fid,type)';
catch exception
    % close file
    fclose(fid);
	throw(exception);
end

% close file
fclose(fid);
