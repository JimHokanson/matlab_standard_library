function file_name = getFileName(file_path_or_object)
%
%
%       file_name = sl.dir.getFileName(file_path_or_object)

if ischar(file_path_or_object)
    [~,file_name] = fileparts(file_path_or_object);
elseif isjava(file_path_or_object)
    file_name = char(file_path_or_object.getName);
else
    error('Unrecognized type')
end
