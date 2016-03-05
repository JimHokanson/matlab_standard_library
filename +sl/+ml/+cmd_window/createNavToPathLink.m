function str = createNavToPathLink(file_or_folder_path,display_text)
%x Creates a link that will launch an OS window when clicked to path
%
%   str = sl.ml.cmd_window.createNavToPathLink(file_or_folder_path,*display_text)
%   
%   Inputs:
%   -------
%   file_or_folder_path : string
%       Path to a file or folder.
%
%   Optional Inputs:
%   ----------------
%   display_text : default (uses 'file_or_folder_path' value)
%
%   See Also:
%   ---------
%   sl.os.navToPath
%   sl.error.getMissingFileErrorMsg

if ~exist('display_text','var')
   display_text = file_or_folder_path;
end

command_str = sprintf('sl.os.navToPath(''%s'')',file_or_folder_path);
str = sl.ml.cmd_window.createLinkForCommands(display_text,command_str);

end