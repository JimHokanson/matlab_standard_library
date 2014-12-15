function str = createNavToPathLink(file_or_folder_path)
%x Creates a link that will launch an OS window when clicked to path
%
%   str = sl.cmd_window.createNavToPathLink(file_or_folder_path)
%   
%   Inputs:
%   -------
%   file_or_folder_path : string
%       Path to a file or folder.
%
%   See Also:
%   ---------
%   sl.os.navToPath
%   sl.error.getMissingFileErrorMsg

command_str = sprintf('sl.os.navToPath(''%s'')',file_or_folder_path);
str = sl.cmd_window.createLinkForCommands(file_or_folder_path,command_str);

end