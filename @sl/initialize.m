function initialize()
%
%   Add to this anything that needs to be run on initialization of the
%   standard library.
%   

repo_root = sl.stack.getPackageRoot;

cd(fileparts(repo_root));

addpath(fullfile(repo_root,'global_namespace_functions'))

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