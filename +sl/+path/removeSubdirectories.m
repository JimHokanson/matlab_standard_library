function removeSubdirectories(base_path,varargin)
%x  Remove all subdirectories in path given a starting directory.
%   
%   sl.path.removeSubdirectories(base_path,varargin)
%
%   Inputs:
%   -------
%   base_path : string
%       The directory whose subdirectories should be removed from the path.
%
%   Optional Inputs:
%   ----------------
%   include_base_path : logical (false)
%       If true, the base path is removed as well.
%
%   Improvements:
%   -------------
%   1) Consider a direct write to matlabpath as the rmpath is UGLY!
%   2) Array of base paths as an input
%
%   Examples:
%   ---------
%   sl.path.removeSubdirectories(...
%       '/Users/jameshokanson/repos/matlab_SVN','include_base_path',true)
%
%   See Also:
%   ---------
%   rmpath
%   matlabpath
%   pathsep

in.include_base_path = false;
in = sl.in.processVarargin(in,varargin);

path_entries = sl.path.asCellstr();

paths_remove_mask = sl.path.matchSubdirectories(path_entries,base_path,...
    'include_base_path',in.include_base_path);

%NOTE: This would be quicker as a direct call to matlabpath with only
%the paths we want to keep
if any(paths_remove_mask)
   paths_remove = path_entries(paths_remove_mask);
   
   %path_lengths = cellfun('length',paths_remove);
   
   rmpath(paths_remove{:});
end

end