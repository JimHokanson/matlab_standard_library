function str = openFileToLine(file_path, line, display_str, varargin)
%createOpenToLineLink  Produces a string, that when printed, creates a link to a specific file and line
%
%   str = sl.str.create_clickable_cmd.createOpenToLineLink(file_path, line, display_text, varargin)
%
%   The created links operate like those produced when an error is thrown.
%
%   Inputs:
%   -------   
%   file_path : (string) 
%       full path to file to open
%   line : (numeric) 
%       file to open
%   display_str : (string) 
%       displayed link text, this is often the file name
%
%   Optional Inputs:
%   ----------------
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