function file_extension = getFileExtension(file_path)
%
%   file_extension = sl.file_path.getFileExtension(file_path)
%

[~,~,file_extension] = fileparts(file_path);

end