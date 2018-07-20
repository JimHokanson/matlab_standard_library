function bytes = readBytes(file_path)
%x Read a file as bytes
%
%   bytes = sl.io.readBytes(file_path)
%
%   See Also
%   --------
%   sl.io.fileRead

bytes = sl.io.fileRead(file_path,'*uint8');

end