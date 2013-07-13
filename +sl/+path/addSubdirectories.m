function addSubdirectories(base_paths,varargin)
%addSubdirectories  Adds subdirectories to the path
%
%   sl.path.addSubdirectories(base_paths,varargin)
%
%   This function was written to facilitate adding
%
%   INPUTS
%   =======================================================================
%   base_paths : (char or cellstr), must be absolute paths
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Move the code that gets directories to add to a separate function
%   with perhaps a flag to allow adding. This function would probably
%   be deleted -> getCodeSubdirectories????
%
%
%   See Also:
%   sl.dir.searcher.folder_default
%   genpath

%NOTE: We can allow a cell array for base_path as well ...

in.dirs_ignore   = {'private'};
in.add_base_path = 'false';
in = sl.in.processVarargin(in,varargin);

%Construction of the search object
%--------------------------------------------------------------------------
obj = sl.dir.searcher.folder_default;
opt = obj.filter_options;
opt.first_chars_ignore = '.+@'; %Should I expose these?
opt.dirs_ignore        = in.dirs_ignore;

%Initializaton of paths to add
%--------------------------------------------------------------------------
if ischar(base_paths)
    base_paths = {base_paths};
end

if in.add_base_path
    all_paths_add = base_paths;
else
    all_paths_add = {};
end

%The main function
%--------------------------------------------------------------------------
n_base_paths = length(base_paths);
for iBase = 1:n_base_paths
   temp_file_paths = obj.searchDirectories(base_paths{iBase});
   all_paths_add   = [all_paths_add temp_file_paths]; %#ok<AGROW>
end

addpath(all_paths_add);