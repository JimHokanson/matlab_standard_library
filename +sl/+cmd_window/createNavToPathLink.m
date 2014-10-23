function str = createNavToPathLink(file_path)
%
%   str = sl.cmd_window.createNavToPathLink(file_path)
%   

command_str = sprintf('sl.os.navToPath(''%s'')',file_path);
str = sl.cmd_window.createLinkForCommands(file_path,command_str);


end