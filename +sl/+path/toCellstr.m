function path_entries = toCellstr(path_string)
%
%
%   path_cell_array = sl.path.toCellstr(path_string)

path_entries = regexp(path_string,pathsep,'split');
if isempty(path_entries(end))
    path_entries(end) = [];
end

end