function addSubdirectories(base_paths,varargin)
%x  Adds subdirectories to the path
%
%   sl.path.addSubdirectories(base_paths,varargin)
%
%   Recursively adds all subdirectories in a folder to the path. This is
%   similar to the functionality provided in Matlab by the graphical 
%   "set path" tool but it provides finer control over what is added.
%
%   This would typically get called in a startup.m script.
%
%   
%   Inputs:
%   -------
%   base_paths : (char or cellstr)
%       Must be absolute paths. In order to remove some verbosity the input
%       may be a cell array of paths, rather than calling this function
%       multiple times for each base path.
%
%   Hardcoded Values:
%   -----------------
%   Directories that start with the following characters are ignored:
%       '+' (packages) 
%       '.' (many hidden directories)
%       '@' (classes)
%
%   Optional Inputs:
%   ----------------
%   dirs_ignore : {'private'};
%   add_base_path : (default false)
%       If true, then the base path is added
%   start_dirs : (char or cellstr) NOT YET IMPLEMENTED
%       The idea is that these folders would get added to a singular input
%       base path and then become the base_paths from which this function
%       is run.
%
%   Examples:
%   ---------
%   1) 
%   sl.path.addSubdirectories('/Users/jameshokanson/repos/matlab_SVN',...
%       'add_base_path',true)
%
%   2)
%   This adds recursively starting at 3 different root folders.
%
%   base_path = '/Users/jameshokanson/repos/'
%   ff = @(x)fullfile(base_path);
%   sl.path.addSubdirectories({ff('matlab_SVN'),ff('old_code'),ff('new_code')})
%
%
%
%   Improvements:
%   -------------   
%   1) Not sure if we also need to ignore __MACOSX on windows (& unix)
%   maybe just best to ignore _ in general?????
%   2) Allow specification of a single base folder and then multiple 
%   'starting folders' inside that base folder. This should make the 2nd
%   example more simple to understand
%
%   See Also:
%   ---------
%   sl.dir.getList
%   genpath


%NOTE: We can allow a cell array for base_path as well ...

%??? -> Ignore __MACOSX on windows?

FIRST_CHARS_IGNORE = '+.@'; %Should I expose these? If I do then
%we would want to make sure these exist in addition to any entries the user
%provides

in.dirs_ignore   = {'private'};
in.add_base_path = false;
in = sl.in.processVarargin(in,varargin);


%Initializaton of paths to add
%-----------------------------
if ischar(base_paths)
    base_paths = {base_paths};
end

if in.add_base_path
    all_paths_add = base_paths(:);
else
    all_paths_add = {};
end

%The main function
%----------------------------------
n_base_paths = length(base_paths);
for iBase = 1:n_base_paths
   cur_base_path = base_paths{iBase};
   temp_file_paths = sl.dir.getList(cur_base_path,...
       'folders_to_ignore',in.dirs_ignore,...
       'first_chars_in_folders_to_ignore',FIRST_CHARS_IGNORE,...
       'recursive',true,...
       'output_type','paths',...
       'search_type','folders');    
   all_paths_add   = [all_paths_add; temp_file_paths]; %#ok<AGROW>
end

addpath(all_paths_add{:});