function fileWrite(file_path,data,varargin)
%x Write an array to disk
%
%   sl.io.fileWrite(file_path,data)
%
%   TODO: Finish documentation
%
%   This is a thin wrapper around fwrite that takes care of opening and
%   closing a file.
%
%   Optional Inputs
%   ---------------
%   mode : (Default 'w')
%   endian : (Default 'n')
%   encoding : (Default '')
%
%   Examples:
%   ---------
%   1) Write a string to disk
%   sl.io.fileWrite(file_path,'testing testing 123')

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