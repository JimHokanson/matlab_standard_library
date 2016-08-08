function str = editFile(file_to_edit,display_text)
%x Creates a clickable string that opens the specified file in the editor
%
%   str = sl.str.create_clickable_cmd.editFile(file_to_edit,*display_text)
%
%   Inputs:
%   -------
%   file_to_edit : string
%       Name of the file to edit
%   display_text : string (optional)
%       text to display instead of the name of the file
%
%   Example:
%   --------
%   1)
%   str = sl.str.create_clickable_cmd.editFile('sl.in.processVarargin');
%   disp(str)   
%
%   2)
%   str = sl.str.create_clickable_cmd.editFile('sl.in.processVarargin','Click to edit option processor');
%   disp(str)  

if ~exist('display_text','var')
   display_text = file_to_edit;
end

command_str = sprintf('edit(''%s'')',file_to_edit);

str = sl.ml.cmd_window.createLinkForCommands(display_text,command_str);

end