function str = navigateToFileInOS(file_or_folder_path,display_text)
%x Creates clickable link to path via opening OS windows (e.g. finder/explorer) 
%
%   str = sl.str.create_clickable_cmd.navigateToFileInOS(file_or_folder_path,*display_text)
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
%   Examples:
%   ---------
%   1) 
%   str = sl.str.create_clickable_cmd.navigateToFileInOS('C:\open\to\this\path');
%   disp(str)
%
%   str = 'C:\open\to\this\path'
%          --------------------
%
%   2) 
%   str = sl.str.create_clickable_cmd.navigateToFileInOS('C:\open\to\this\path','file_path');
%   disp(str)
%   
%   str = 'file_path'   <= clicking opens to 'C:\open\to\this\path'
%         -----------
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