function addSubdirectories(base_paths,varargin)
%
%
%   sl.path.addSubdirectories(base_paths)
%
%   INPUTS
%   =======================================================================
%   base_paths : (char or cellstr), must be absolute paths
%   
%   See Also:
%   sl.dir.searcher.folder_default

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
   temp_file_paths = obj.searchDirectories(base_paths{iBase});
   all_paths_add   = [all_paths_add temp_file_paths]; %#ok<AGROW>
end

addpath(all_paths_add);