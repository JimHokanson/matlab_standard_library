function initialize()
%
%   Add to this anything that needs to be run on initialization of the
%   standard library.
%   

repo_root = sl.stack.getPackageRoot;

%repo_root - points to folder containing +sl, not +sl itself

cd(fileparts(repo_root));

addpath(fullfile(repo_root,'global_namespace_functions'))

%TODO: I added a non-existant path and javaaddpath didn't say anything
%I also don't want to add if it is already added
%make a function that makes this nice
java_jar_path = fullfile(repo_root,'src','java');
sigar_path = fullfile(java_jar_path,'sigar','sigar.jar');
javaaddpath(sigar_path);

%javaaddpath('C:\D\repos\matlab_git\mat_std_lib\src\java\sigar\sigar.jar')



%TODO: Change this ...
%
% %Let's first check that the class is not in the static path
% if NEURON.comm_obj.java_comm_obj.validate_installation
%     %Do nothing
% else
    %javaaddpath(sl.java.read_buffered_stream);
    sl.git.initialize()
% end

end