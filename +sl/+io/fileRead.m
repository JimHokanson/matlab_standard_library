function out = fileRead(file_path,type,varargin)
%x Read a file as a given data type
%
%   out = sl.io.fileRead(file_path,type,varargin)
%
%   Similiar to fileread() except that it allows specification of a single
%   fread type, like uint8.
%
%   This is basically a very thin wrapper around fread that also takes
%   care of opening and closing the file.
%
%   Inputs:
%   -------
%   type : 
%       Passed directly into fread.
%       Notes on type from fread documentation:
%       'uint8' read as uint8 but output as double
%       'uint8=>single' read as uint8, output as single
%       '*uint8' read and return as uint8
%       
%
%   Optional Inputs:
%   ----------------
%   endian : (default 'n')
%
%   Examples:
%   ---------
%   1) Read and return as uint8
%   out = sl.io.fileRead(file_path,'*uint8')
%
%   2) Read and return as characters
%   out = sl.io.fileRead(file_path,'*char')
%
%   See Also:
%   ---------
%   fread

in.mode = 'r';
in.endian = 'n';
in.encoding = '';
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

mode = in.mode;
in = rmfield(in,'mode');

% open the file

fid = sl.io.fopenWithErrorHandling(file_path,mode,in);

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

