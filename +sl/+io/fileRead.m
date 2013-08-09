function out = fileRead(file_path,type)
%
%
%   out = sl.io.fileRead(file_path,type)
%
%   Inputs
%   -----------------------------------------------------------------------
%   type : passed directly into fread
%
%   example:
%   -------------------------------------------------------------
%   out = sl.io.fileRead(file_path,*uint8)

if ~exist(file_path,'file')
    error('Specified file does not exist:\n%s\n',file_path)
end

% open the file
[fid, msg] = fopen(file_path,'r');
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
