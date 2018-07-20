function runc(varargin)
%x Run a commented example that is in the clipboard
%
%   runc()
%
%   I wrote this function to facilitate running multi-line examples from
%   files. I would normally need to uncomment the lines, evaluating the
%   selection (being careful not to save the file), and then undo the
%   changes so that the file wasn't changed.
%
%   Flags
%   -----
%   last - use last command
%   disp - display the command in the command window
%   raw  - don't uncomment
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
%   1) Allow running code without uncommenting - this would allow
%   evaluating a selection that isn't commented but would still provide
%   the ability to determine where errors were in the selection
%   2) runc last


%{
%This is test code for runc('raw')
x = 1;
b = 2;
%This should throw an error
c = x(b); 
%}

%%Testing file writing
%   %first run (copy line below then run this function)
%   a = 1
%   %2nd run   (copy lines below then run this function)
%   b = 1:5
%   b(10)  %Should cause an error in the file

persistent last_input_string

in.use_last = false; %flag - last
in.show_code = false; %flag - disp
in.is_raw = false;
%TODO: Write a formal function that handles this ...
if any(strcmp(varargin,'last'))
   in.use_last = true; 
end
if any(strcmp(varargin,'disp'))
   in.use_last = true; 
end
if any(strcmp(varargin,'raw'))
   in.is_raw = true; 
end


%TODO: I don't think this is needed anymore
%This is also unfortunately in sl.initialize due to Matlab not allowing
%dynamically created functions
TEST_FILE_NAME = 'z_runc_exec_file.m';

script_name = TEST_FILE_NAME(1:end-2); 

if in.use_last
    if isempty(last_input_string)
        fprintf(2,'Last execution string was cleared or never initialized\n');
    end
    str = last_input_string;
else
    str = clipboard('paste');
end
    
if in.is_raw
    uncommented_str = str;
else
    %TODO: figure out whether to run raw or not ...
    %1) look for # of newlines
    %2) look for # of commments
    %3) If we have more newlines than comments, run raw
    
    %temp = regexp(str,'^\s*%\s*','lineanchors');
    
    %This fails when we strip multiple lines
    %   e.g.:
    %
    %     %  %Good Comment
    %     %
    %     %  n = 1
    %     %  x = 2
    %
    %   The n = 1 doesn't get uncommented because we consume the leading
    %   whitespace since the previous line doesn't have any text
    %   %%uncommented_str = regexprep(str,'^\s*%\s*','','lineanchors');
    
    %https://stackoverflow.com/questions/3469080/match-whitespace-but-not-newlines
    uncommented_str = regexprep(str,'^\s*%[^\S\n]*','','lineanchors');
end


if in.show_code
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


%NOTE: If this fails here see the file:
%
%   z_runc_exec_file.m
%
%   Or click on the link in the command window
if run_file
    evalin('caller',script_name);
else
    evalin('caller',uncommented_str);
end

%JAH Note:
%- compile errors get thrown here :/
%- runtime errors get thrown from file as desired

end
