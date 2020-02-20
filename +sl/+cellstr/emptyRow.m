function flag = emptyRow(data,row_indices)
%
%   flag = sl.cellstr.emptyRow(data,row_indices)

flag = false(length(row_indices),1);

for i = 1:length(row_indices)
    cur_row_I = row_indices(i);
    n = cellfun('length',data(cur_row_I,:));
    flag(i) = all(n == 0);
end



end