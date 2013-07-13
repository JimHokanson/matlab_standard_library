function path_entries = toCellstr(path_string)
%sl.path.toCellstr  Parses a path string into a cellstr
%
%   path_cell_array = sl.path.asCellstr(path_string)
%
%   OUTPUTS
%   ======================================================================
%   path_cell_array : {n x 1}, cellstr
%
%   See Also:
%   sl.path.toCellstr

path_entries = regexp(path_string,pathsep,'split')';
if isempty(path_entries(end))
    path_entries(end) = [];
end

end