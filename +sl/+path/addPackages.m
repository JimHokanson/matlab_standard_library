function addPackages(package_folders,varargin)
%x Adds folders with code to the path
%
%   sl.path.addPackages(package_parent_folders_or_full_paths,varargin)
%
%   This function is meant to facilitate adding code to the path on
%   startup.
%
%   Initialization Scripts
%   ----------------------
%   Note, if the folder contains an initialization script, "initialize.m"
%   this is run rather than adding the folder to the path. If a package
%   (i.e., folder with leading '+' character) is added to the path, the
%   code also looks for a .initialize
%
%   Inputs
%   ------
%   package_parent_folders_or_full_paths : string or cellstr
%           
%       - package_parent_folder : path is relative to the standard library root
%                          and is the NAME of the parent folder
%       - full_path : full path to add to MATLAB path
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
        if ~exist(cur_package_path,'dir')
            sl.warning.formatted('package folder missing, not added to path:\n%s',cur_package_path)
        else
            addpath(cur_package_path);
            %Note, this is non-recursive, just the name of the folder
            %may not match the name of the package so we put the wildcard
            %in ...
            path_to_test = fullfile(cur_package_path,'+*');
            %We support multiple packages in this folder
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
end