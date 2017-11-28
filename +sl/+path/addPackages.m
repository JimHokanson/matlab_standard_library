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
%   Inputs
%   ------
%   package_folders : string or cellstr
%       These are the names of packages to add OR the paths. Paths are
%       useful for initialization handling. Packages should be in folders 
%       that are at the same level as the standard library (when using
%       names)
%
%               e.g.,
%               /matlab_standard_library
%               /labchart_server_matlab/+labchart
%               /turtle_json/initialize.m
%
%
%   Optional Inputs
%   ---------------
%   root_path : string
%       The default is to use the parent directory that holds the standard
%       library.
%
%   Example
%   -------------------------------------------
%   sl.path.addPackages({'ad_sdk','bladder_analysis',...
%     'labchart_server_matlab','mex_maker',...
%     'harvard_apparatus_pump_matlab','jims_expt_control',...
%     'multichannel_systems_stg_matlab'})
%
%   Improvements
%   -------------------------------------------
%   1) Support loose name matching
%   2) Support relative paths to standard library

in.root_path = fileparts(sl.stack.getPackageRoot);
in = sl.in.processVarargin(in,varargin);

if ischar(package_folders)
    package_folders = {package_folders};
end

for iPackage = 1:length(package_folders)
    cur_package_name = package_folders{iPackage};

    if exist(cur_package_name,'dir')
        cur_package_path = cur_package_name;
    else
        cur_package_path = fullfile(in.root_path,cur_package_name);
    end

    init_path = fullfile(cur_package_path,'initialize.m');
    if exist(init_path,'file')
        run(init_path)
    else        
        addpath(cur_package_path);
        path_to_test = fullfile(cur_package_path,'+*');
        d = dir(path_to_test);
      	for i = 1:length(d)
            package_name = d(i).name(2:end);
            init_cmd = [package_name '.initialize'];
            if ~isempty(which(init_cmd))
               feval(init_cmd); 
            end
        end
    end
end