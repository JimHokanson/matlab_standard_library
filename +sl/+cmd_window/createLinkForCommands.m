function str = createLinkForCommands(disp_str,command_str)
%x Creates a clickable link that executes a matlab command
%
%   str = sl.cmd_window.createLinkForCommands(disp_str,command_str)
%
%   Inputs:
%   -------
%   disp_str    : String to display in the link
%   command_str : String of the command to run. This shold NOT include the 
%       matlab prefix as this is done in this function.
%
%   OUTPUTS
%   ===========================================================
%   str : string to display
%
%   EXAMPLE
%   ===========================================================
%   str = sl.cmd_window.createLinkForCommands('show_random_numbers','rand(1,5)');
%   disp(str)

str = sprintf('<a href="matlab:%s">%s</a>',command_str,disp_str);