function function_name = toFunctionName(file_path)
%
%   function_name = sl.file_path.toFunctionName(file_path)
%   
%   Returns the function name, given the file_path. In particular,
%   this resolves packages and class folder.
%

info = sl.file_path.info(file_path);
function_name = info.full_name;

end