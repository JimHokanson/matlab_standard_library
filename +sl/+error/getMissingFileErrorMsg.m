function error_msg = getMissingFileErrorMsg(file_or_folder_path,varargin)
%x Returns a message that helps the user to understand why a file is missing
%
%   error_msg = sl.error.getMissingFileErrorMsg(file_or_folder_path,varargin)
%
%   This function is meant to facilitate handling when a file is missing.
%   It only returns a formatted message. It does not actually display the
%   error (or warning).
%
%   The message returned is clickable (opens explorer or finder) to the 
%   deepest level that exists relative to the file.
%
%   For example, let's say the following is missing:
%   C:\repos\matlab_git\bladder_analysis\data_files\cmg_info\1401416_C.csv
%   and that the 'cmg_info' folder is missing as well
%
%   The output will be:
%
%   Missing file:
%   C:\repos\matlab_git\bladder_analysis\data_files\cmg_info\1401416_C.csv
%   ________________________________________________
%
%                                 /\  
%   Line above would be clickable ||
%   
%
%
%   Inputs:
%   -------
%   file_or_folder_path : string
%       Path to a file or folder.
%
%   Optional Inputs:
%   ----------------
%   msg_prefix : string     (Default 'Missing file':)
%       How to prefix the missing file link.
%   
%   Outputs:
%   --------
%   error_msg : string
%       Note, by passing out a string, the error can be thrown in the
%       caller, thus not cluttering up the stack and making the location
%       of the error more obvious. There is a throwAsCaller function but
%       it doesn't work well when debugging is enabled.
%
%
%   Examples:
%   ---------
%   1)
%       if ~exist(file_path,'file')
%          error_msg = sl.error.getMissingFileErrorMsg(file_path)
%          error(error_msg)
%       end
%
%   Improvments:
%   ------------
%   1) Allow passing in the name of the variable from the caller. Or can 
%   we just grab this ????
%
%   I'd like this to facilitate navigating to a path to see
%   why a file is missing ...
%
%   2) 
%


in.msg_prefix = 'Missing file:';
in = sl.in.processVarargin(in,varargin);

if isempty(file_or_folder_path)
   error_msg = 'The path variable was empty'; %See improvment #1
   return
end



existing_base_path = '';
root_path = fileparts(file_or_folder_path);
while ~isempty(root_path)
   if exist(root_path,'dir')
       existing_base_path = root_path;
       break
   end
   next_root_path = fileparts(root_path);
   if strcmp(next_root_path,root_path)
      %TODO: This generally indicates that the drive letter is incorrect 
      %on Windows. However it also occurs when the path is not valid.
      %
      %     e.g. C:\data\C:\data
      %
      %  Can we distinguish these cases and throw a more specific errro
      %  msg?
      error_msg = sprintf('The entire path is non-existant:\n%s',file_or_folder_path);
      return
   end
   root_path = next_root_path;
end

if isempty(existing_base_path)
    error_msg = sprintf('%s:\n%s\n',in.msg_prefix,file_or_folder_path);
else
    start_I = length(existing_base_path)+1;
    remaining_str = file_or_folder_path(start_I:end);
    
    link_to_existing_path = sl.ml.cmd_window.createNavToPathLink(existing_base_path);
    
    error_msg = sprintf('%s:\n%s%s\n',in.msg_prefix,link_to_existing_path,remaining_str);
end



end