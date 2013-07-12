function removeSubdirectories(base_path)
%removeSubdirectories Remove all subdirectories in path given base path
%   
%   sl.path.removeSubdirectories(base_path)
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Allow removal of base path as well ...
%   2) Consider a direct write to matlabpath as the rmpath is UGLY!
%
%   See Also:
%   rmpath
%   matlabpath
%   pathsep

path_entries = sl.path.asCellstr();

paths_remove_mask = strncmp(base_path,path_entries,length(base_path));

%NOTE: This would be quicker as a direct call to matlabpath with only
%the paths we want to keep
if any(paths_remove_mask)
   paths_remove = path_entries(paths_remove_mask); 
   rmpath(paths_remove{:});
end

end