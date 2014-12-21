function runc(show_code)
%x Run a commented example that is in the clipboard
%
%   runc()
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

%{
  disp('Select this line')
  disp('And select this one!')

%}

if nargin == 0
   show_code = false; 
end


str = clipboard('paste');

uncommented_str = regexprep(str,'^\s*%\s*','','lineanchors');

if show_code
    disp(uncommented_str)
end

eval(uncommented_str)

end