function initialize()
%
%   Add to this anything that needs to be run on initialization of the
%   standard library.

%We'll check for a file to make sure we are in the right place
std_lib_check_file_path = fullfile(cd,'is_mat_std_lib.txt');

if ~exist(std_lib_check_file_path,'file')
   error('This function is meant to be run with the current directory set to the std lib repo') 
end

addpath(cd);
addpath(fullfile(cd,'global_namespace_functions'))

%TODO: Change this ...
%
% %Let's first check that the class is not in the static path
% if NEURON.comm_obj.java_comm_obj.validate_installation
%     %Do nothing
% else
    %javaaddpath(sl.java.read_buffered_stream);
    javaaddpath(sl.git.getJarBasePath);
% end

end