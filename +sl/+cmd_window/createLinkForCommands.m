function str = createLinkForCommands(disp_str,command_str)
%createLinkForCommands
%
%   str = sl.cmd_window.createLinkForCommands(disp_str,command_str)
%
%   INPUTS
%   ===========================================================
%   disp_str    : String to display in the link
%   command_str : String of the command to run
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