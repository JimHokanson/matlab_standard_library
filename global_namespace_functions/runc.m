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

%One strange bug I ran into is when these files are read into memory.
%In 2015a I needed to execute this function twice before the contents of
%the file had been updated in Matlab memory. Is this a race condition?

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
file_path = fullfile(function_dir,TEST_FILE_NAME);

if exist(file_path,'file')
   delete(file_path);
   pause(0.5)
end

try
    sl.io.fileWrite(file_path,uncommented_str);
    %pause(1); %Adding to test race condition
    %Doesn't seem to be a race condition
    run_file = exist(name_without_ext,'file');
catch ME
    run_file = false; 
end

if run_file
    %A timer won't work since it executes in neverland, not in the 
    %main thread like we want ...
    %t = timer('ExecutionMode','singleShot','TimerFcn',@(~,~) h__runCode(name_without_ext),'StartDelay',0.5);
    %start(t);
    
    %Doesn't make a difference
    %drawnow()
    
    evalin('base',name_without_ext);
else
    evalin('base',uncommented_str);
end

end

function h__runCode(name_without_ext)
    evalin('base',name_without_ext);
end