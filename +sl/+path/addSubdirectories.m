function addSubdirectories(base_paths,varargin)
%addSubdirectories  Adds subdirectories to the path
%
%   sl.path.addSubdirectories(base_paths,varargin)
%
%   INPUTS
%   =======================================================================
%   base_paths : (char or cellstr), must be absolute paths
%
%   OPTIONAL INPUTS
%   =======================================================================
%   dirs_ignore: {'private'};
%   add_base_path: (default false)
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Move the code that gets directories to add to a separate function
%   with perhaps a flag to allow adding. This function would probably
%   be deleted -> getCodeSubdirectories????
%   2) Not sure if we also need to ignore __MACOSX on windows (& unix)
%   maybe just best to ignore _ in general?????
%
%   See Also:
%   sl.dir.searcher.folder_default
%   genpath

%NOTE: We can allow a cell array for base_path as well ...

%??? -> Ignore __MACOSX on windows?

in.dirs_ignore   = {'private'};
in.add_base_path = false;
in = sl.in.processVarargin(in,varargin);

%Construction of the search object
%--------------------------------------------------------------------------
obj = sl.dir.searcher.folder_default;
opt = obj.filter_options;
opt.first_chars_ignore = '+.@'; %Should I expose these? If I do then
%we would want to make sure these exist in addition to any entries the user
%provides
opt.dirs_ignore        = in.dirs_ignore;

%Initializaton of paths to add
%--------------------------------------------------------------------------
if ischar(base_paths)
    base_paths = {base_paths};
end

if in.add_base_path
    all_paths_add = base_paths(:);
else
    all_paths_add = {};
end

%The main function
%--------------------------------------------------------------------------
n_base_paths = length(base_paths);
for iBase = 1:n_base_paths
   temp_file_paths = obj.searchDirectories(base_paths{iBase});
   all_paths_add   = [all_paths_add; temp_file_paths]; %#ok<AGROW>
end

addpath(all_paths_add{:});