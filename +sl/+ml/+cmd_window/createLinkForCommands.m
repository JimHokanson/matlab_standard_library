function str = createLinkForCommands(disp_str,command_str)
%x Creates a clickable link that executes a matlab command
%
%   str = sl.ml.cmd_window.createLinkForCommands(disp_str,command_str)
%
%   This function generates a string that when displayed in the Matlab
%   command window will run the given command.
%
%   Inputs:
%   -------
%   disp_str : string
%       String to display in the link.
%   command_str : string
%       String of the command to run. This shold NOT include the 
%       matlab prefix as this is done in this function.
%
%   Outputs:
%   --------
%   str : string
%       The string to display
%
%   Example:
%   --------
%   str = sl.cmd_window.createLinkForCommands('show_random_numbers','rand(1,5)');
%   disp(str)

str = sprintf('<a href="matlab:%s">%s</a>',command_str,disp_str);