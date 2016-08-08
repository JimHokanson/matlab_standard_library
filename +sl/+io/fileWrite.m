function fileWrite(file_path,data,varargin)
%x Write an array to disk
%
%   sl.io.fileWrite(file_path,data)
%
%   This is a thin wrapper around fwrite that takes care of opening and
%   closing a file.
%
%   Optional Inputs
%   ---------------
%   mode : (Default 'w')
%       The mode with which to open the file.
%       - 'w' open file for writing; discard existing contents
%       - 'a' open file for writing, append data to end of file
%   endian : (Default 'n')
%       - 'n' local machine format
%       - 'l' little-endian
%       - 'b' big-endian
%       - 'a' little-endian with 64 bit long data type
%       - 's' big-endian with 64 bit long data type
%   encoding : (Default '')
%       Specifies the character encoding scheme such as:
%       - 'UTF-8'
%       - 'latin1'
%       - 'Shift_JIS'
%
%   Improvements:
%   -------------
%   1) Create an option 'append' (logical) that is equivalent to mode.
%
%   Examples:
%   ---------
%   1) Write a string to disk
%   sl.io.fileWrite(file_path,'testing testing 123')
%
%   See Also:
%   ---------
%   sl.io.fopenWithErrorHandling

in.mode = 'w';
in.endian = 'n';
in.encoding = '';
in = sl.in.processVarargin(in,varargin);

mode = in.mode;
in = rmfield(in,'mode');

fid = sl.io.fopenWithErrorHandling(file_path,mode,in);
    
try
    % read file
    fwrite(fid,data);
catch exception
    % close file
    fclose(fid);
    throw(exception);
end

% close file
fclose(fid);