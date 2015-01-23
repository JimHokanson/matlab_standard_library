function str = createOpenToLineLink(file_path, line, display_str, varargin)
%createOpenToLineLink  Produces a string, that when printed, creates a link to a specific file and line
%
%   str = sl.cmd_window.createOpenToLineLink(file_path, line, display_text, varargin)
%
%   The created links operate like those produced when an error is thrown.
%
%   INPUTS
%   =========================================================================
%   file_path    : (string) full path to file to open
%   line         : (numeric) file to open
%   display_str  : (string)  displayed link text, this is often the file name
%
%   OPTIONAL INPUTS
%   =========================================================================
%   proceeding_commands : (char, default ''), text to evaluate before the open 
%                        to line link. This was originally implemented 
%                        for placting a keyboard statement dynamically
%                        in which 'dbup' proceeded the open command
%
%   tags: utility, text
  
in.proceeding_commands = '';
in = sl.in.processVarargin(in,varargin);

command_str = sprintf('%s opentoline(''%s'',%d,1)',in.proceeding_commands,file_path,line);

str = sl.ml.cmd_window.createLinkForCommands(display_str,command_str);


%str = sprintf('<a href="matlab: %s opentoline(''%s'',%d,1)">%s</a>',text_proceeding_open,file_path, line, display_text);