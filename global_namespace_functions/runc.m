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

%%Testing file writing
%   %first run (copy line below then run this function)
%   a = 1
%   %2nd run   (copy lines below then run this function)
%   b = 1:5
%   b(10)  %Should cause an error in the file

%TODO: I don't think this is needed anymore
%This is also unfortunately in sl.initialize due to Matlab not allowing
%dynamically created functions
TEST_FILE_NAME = 'z_runc_exec_file.m';

script_name = TEST_FILE_NAME(1:end-2); 

if nargin == 0
   show_code = false; 
end

str = clipboard('paste');

uncommented_str = regexprep(str,'^\s*%\s*','','lineanchors');

if show_code
    disp(uncommented_str)
end

function_dir = sl.stack.getMyBasePath();
file_path = fullfile(function_dir,TEST_FILE_NAME);

if exist(file_path,'file')
   clear(script_name)
end

try
    sl.io.fileWrite(file_path,uncommented_str);
    %pause(1); %Adding to test race condition
    %Doesn't seem to be a race condition
    run_file = exist(script_name,'file');
catch ME
    run_file = false; 
end

%TODO: Do I ever want to do 'caller' instead? Is 'caller' preferred?
if run_file
    evalin('base',script_name);
else
    evalin('base',uncommented_str);
end

end
