function new_file_path = changeFileName(old_file_path,new_name)
%
%   new_file_path = sl.dir.changeFileName(old_file_path,new_name)
%
%   Inputs
%   ------
%   old_file_path:
%   new_name:
%
%   Outputs
%   -------
%   new_file_path
%
%   Example
%   --------
%   TODO :)

[path_str,~,ext] = fileparts(old_file_path);

new_file_path = fullfile(path_str,[new_name '.' ext]);


end