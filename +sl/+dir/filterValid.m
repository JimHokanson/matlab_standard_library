function out = filterValid(file_paths)
%
%   out = sl.dir.filterValid(file_paths)

n_files = length(file_paths);
keep_mask = false(1,n_files);
for i = 1:n_files
    file_path = file_paths{i};
    keep_mask(i) = exist(file_path,'file') || exist(file_path,'dir');
end
out = file_paths(keep_mask);

end