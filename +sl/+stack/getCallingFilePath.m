function file_path = getCallingFilePath()
%x Return the file_path of the caller
%
%   file_path = sl.stack.getCallingFilePath()
%   
%   This function is mainly meant for helping to dispaly error info
%   to a user. Having code that does different things based on the calling
%   function is generally discouraged.
%
%   Outputs
%   -------
%   file_path : string
%
%   Examples
%   --------
%   File 1: @ 'C:\temp\file1.m'
%       callF2();
%   File 2: @ 'C:\temp\callF2.m'
%       function callF2()
%           file_path = sl.stack.getCallingFilePath()
%       end
%
%   file_path => 'C:\temp\file1.m'
%

%1 - this
%2 - caller
%3 - caller's caller
temp = sl.stack.calling_function_info(3);
file_path = temp.file_path;
end