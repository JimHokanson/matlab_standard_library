function bytes = readBytes(file_path)
%x Read a file as bytes
%
%   bytes = sl.io.readBytes(*file_path)
%
%   See Also
%   --------
%   sl.io.fileRead

if nargin == 0
    [filename, pathname] = uigetfile('*', 'Pick a file');
    if isequal(filename,0)
        bytes = [];
        return
    end
    file_path = fullfile(pathname,filename);
end



bytes = sl.io.fileRead(file_path,'*uint8');

end