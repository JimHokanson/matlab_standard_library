function file_path = getCallingFilePath()
%
%   file_path = sl.stack.getCallingFilePath()
%   

%1 - this
%2 - caller
%3 - caller's caller
temp = sl.stack.calling_function_info(3);
file_path = temp.file_path;
end