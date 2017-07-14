function new_file_path = changeFileName(old_file_path,new_name,varargin)
%x  Change file name while keeping base path and extension
%
%   new_file_path = sl.dir.changeFileName(old_file_path,new_name,varargin)
%
%   new_file_path = sl.dir.changeFileName(old_file_path,'',varargin);
%       In this case the current file name is used. Useful for adding
%       a prefix or suffix.
%
%
%   Inputs
%   ------
%   old_file_path:
%   new_name:
%
%   Optional Inputs
%   ---------------
%   prefix : string
%   suffix : string
%
%   Outputs
%   -------
%   new_file_path
%
%   Example
%   --------
%   file_path = 'C:\data\my_file.txt';
%   new_file_path = sl.dir.changeFileName(file_path,'your_file')
%   new_file_path => 
%       'C:\data\your_file.txt'
%
%   file_path = 'C:\data\my_file.txt';
%   new_file_path = sl.dir.changeFileName(file_path,'','suffix','2')
%   new_file_path =>
%       C:\data\my_file2.txt
%   

in.suffix = '';
in.prefix = '';
in = sl.in.processVarargin(in,varargin);

[path_str,file_name,ext] = fileparts(old_file_path);

if isempty(new_name)
    new_name = file_name;
end

new_name = [in.prefix new_name in.suffix];

new_file_path = fullfile(path_str,[new_name ext]);


end