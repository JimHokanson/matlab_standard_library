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
%   %Copy the lines below into the clipboard:
%   
%   disp('Select this line')
%   disp('And select this one!')
%   
%   %Then type "runc()" into the command window
%
%   Improvments:
%   ------------
%   1) Write to a temporary file so that errors are assigned to specific
%   locations


if nargin == 0
   show_code = false; 
end

str = clipboard('paste');

uncommented_str = regexprep(str,'^\s*%\s*','','lineanchors');

if show_code
    disp(uncommented_str)
end

evalin('base',uncommented_str);

end