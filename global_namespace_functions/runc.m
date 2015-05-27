function runc(show_code)
%x Run a commented example that is in the clipboard
%
%   runc()
%
%   I wrote this function to facilitate running multi-line examples from
%   files. I would normally need to uncomment the lines, evaluating the
%   selection (being careful not to save the file), and then undo the
%   changes so that the file wasn't changed.
%
%   To Run:
%   -------
%   1) Find some example text to run
%   2) Run this command
%
%   Example:
%   --------
%   1) 
%   %Copy the lines below into the clipboard:
%   
%   disp('Select this line')
%   disp('And select this one!')
%   
%   %Then type "runc()" into the command window
%
%   2) Error in code
%   %Copy below into clipboard then enter 'runc' in command window
%   a = 1:5
%   b = 2*a
%   c = a(6)
%   
%
%   Improvments:
%   ------------
%   1) Write to a temporary file so that errors are assigned to specific
%   locations

%This is also unfortunately in sl.initialize due to Matlab not allowing
%dynamically created functions
TEST_FILE_NAME = 'z_runc_exec_file.m';
name_without_ext = TEST_FILE_NAME(1:end-2);

if nargin == 0
   show_code = false; 
end

str = clipboard('paste');

uncommented_str = regexprep(str,'^\s*%\s*','','lineanchors');

if show_code
    disp(uncommented_str)
end

function_dir = sl.stack.getMyBasePath();
file_path = fullfile(function_dir,TEST_FILE);
code_in_file = true;
try
    sl.io.fileWrite(file_path,uncommented_str);
catch ME
   code_in_file = false; 
end

if code_in_file && exist(name_without_ext,'file')
    evalin('base',name_without_ext);
else
    evalin('base',uncommented_str);
end




end