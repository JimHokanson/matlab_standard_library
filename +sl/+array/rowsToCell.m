function rows_as_cells = rowsToCell(data_in)
%
%   rows_as_cells = sl.array.rowsToCell(data_in)
%

n_rows = size(data_in,1);
rows_as_cells = cell(1,n_rows);
for iRow = 1:n_rows
    rows_as_cells{iRow} = data_in(iRow,:);
end