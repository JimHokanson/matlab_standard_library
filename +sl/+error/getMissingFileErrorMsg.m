function error_msg = getMissingFileErrorMsg(file_or_folder_path)
%
%   error_msg = sl.error.getMissingFileErrorMsg(file_or_folder_path)
%
%   This function is meant to facilitate handling when a file is missing.
%
%   Inputs:
%   -------
%   file_or_folder_path : string
%       path to a file or folder.
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
%   For example, let's say the following is missing:
%   C:\repos\matlab_git\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info\1401416_C.csv
%   I'd like to have a link that allows clicking on a path that does exist
%   ....
%   C:\repos\matlab_git\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info

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
   root_path = fileparts(root_path);
end

if isempty(existing_base_path)
    error_msg = sprintf('Missing file:\n%s\n',file_or_folder_path);
else
    start_I = length(existing_base_path)+1;
    remaining_str = file_or_folder_path(start_I:end);
    
    link_to_existing_path = sl.cmd_window.createNavToPathLink(existing_base_path);
    
    error_msg = sprintf('Missing file:\n%s%s\n',link_to_existing_path,remaining_str);
end



end