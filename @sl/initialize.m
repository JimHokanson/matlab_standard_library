function initialize()
%x Initializes the standard library
%
%   sl.initialize()
%   
%   Add to this anything that needs to be run on initialization of the
%   standard library.

repo_root = sl.stack.getPackageRoot;

%Temp directory creation
%-----------------------
%- originally written for sl.help.current_line_info
if ~exist(sl.TEMP_DIR,'dir')
    mkdir(sl.TEMP_DIR);
end

%repo_root - points to folder containing +sl, not +sl itself

%Why am I changing the directory????
%
%   I believe this is just part of starting out that you are at the root
%   of all the MATLAB repos. I'm not thrilled with it but probably
%   won't change it at this point.
%
cd(fileparts(repo_root));


%Module initialization
%---------------------
sl.modules.initialize();



%Adding other directories
%---------------------------------------------
%This directory holds onto functions/scripts that are called directly
gnf_dir = fullfile(repo_root,'global_namespace_functions');
temp_fcns_dir = fullfile(gnf_dir,'temp__dynamic_functions');
addpath(gnf_dir)
addpath(temp_fcns_dir)

fex_dir = fullfile(repo_root,'fex');
addpath(fex_dir)


%runc support
%---------------------------------------------
%TODO: I don't think this is needed anymore
temp_runc_file_path = fullfile(gnf_dir,'z_runc_exec_file.m');
sl.io.fileWrite(temp_runc_file_path,' ');


%Sigar
%----------------------------------------------------
%sigar - used for memory info
%
%   sl.os.sys_mem_info

%TODO: I added a non-existant path and javaaddpath didn't say anything
%I also don't want to add if it is already added
%make a function that makes this nice
java_jar_path = fullfile(repo_root,'src','java');
sigar_path = fullfile(java_jar_path,'sigar','sigar.jar');
javaaddpath(sigar_path);
end