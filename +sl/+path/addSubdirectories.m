function addSubdirectories(base_paths,varargin)
%
%
%   sl.path.addSubdirectories(base_paths)
%
%   INPUTS
%   =======================================================================
%   base_paths : (char or cellstr), Must currently be absolute paths.


%NOTE: We can allow a cell array for base_path as well ...

in.add_base_path = 'false';



in = sl.in.processVarargin(in,varargin);




if ischar(base_paths)
    base_paths = {base_paths};
end

if in.add_base_path
    all_paths_add = base_paths;
else
    all_paths_add = {};
end

n_base_paths = length(base_paths);
for iBase = 1:n_base_paths
    
end
