function paths_out = fullfileCA(root,paths_in)
%fullfileCA  Appends paths to a root path
% 
%   paths_out = sl.dir.fullfileCA(root,pathsIn)
%
%   Performs the equivalent of fullfile() on each root/pathsIn pair. It
%   tries to accomplish this in the quickest way possible.
%
%   INPUTS
%   =======================================================================
%   root     : (string), root path for appending to
%   paths_in : (cellstr), paths to append to the root
%
%   OUTPUTS
%   =======================================================================
%   paths_out : (cellstr) resultant concatenation of paths
%
%   EXAMPLE
%   =======================================================================
%   root = 'C:\'
%   paths_in = {'test' 'cheese'};
%   paths_out = sl.dir.fullfileCA(root,paths_in)
%   paths_out => 
%       {'C:\test' 'C:\cheese'}
%
%   IMPROVEMENTS
%   =======================================================================
%   1) I don't like the name of this file. I might rename it ...
%
%   See Also:
%   fullfile

fs = filesep;
if root(end) ~= fs
   root = [root fs]; 
end

    n_paths = length(paths_in);
    paths_out = cell(1,n_paths);
    for iPath = 1:n_paths
       paths_out{iPath} = [root paths_in{iPath}];
    end

%CODE ALTERNATIVES
%--------------------------------------------------------------------------
    
    %The above approach takes only about 60% of the time this one takes ...
%     paths_out = cellfun(@makePath_fsPresent,paths_in,'un',0);
% 
%     function myPath = makePath_fsPresent(inputPath)
%         myPath = [root inputPath];
%     end    
    
end