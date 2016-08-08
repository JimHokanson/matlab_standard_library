function addPackages(package_folders,varargin)
%x Adds folders with code to the path
%
%   sl.path.addPackages(package_folders,varargin)
%
%   This function is meant to facilitate adding code to the path on
%   startup.
%
%   Inputs:
%   -------
%   package_folders: string or cellstr
%   
%
%   Optional Inputs:
%   ----------------
%   root_path : string
%       The default is to use the parent directory that holds the standard
%       library.
%

in.root_path = fileparts(sl.stack.getPackageRoot);
in = sl.in.processVarargin(in,varargin);

if ischar(package_folders)
   package_folders = {package_folders}; 
end

for iPackage = 1:length(package_folders)
    cur_package_name = package_folders{iPackage};
   cur_package_path = fullfile(in.root_path,cur_package_name); 
   
   init_path = fullfile(cur_package_path,'initialize.m');
   if exist(init_path,'file')
       run(init_path)
   else
       addpath(cur_package_path);
   end
end