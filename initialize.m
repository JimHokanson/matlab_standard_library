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

end