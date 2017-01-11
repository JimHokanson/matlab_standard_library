function [data,extras] = mergeFromCells(cell_data)
%
%   [data,extras] = sl.array.mergeFromCells(cell_data)

n_each = cellfun('length',cell_data);

n_total = sum(n_each);
data = zeros(1,n_total);
n_arrays = length(cell_data);

end_I = 0;
for iArray = 1:n_arrays
    start_I = end_I + 1; 
    end_I = end_I + n_each(iArray); 
    data(start_I:end_I) = cell_data{iArray};
end

if nargout == 2
    extras = sl.array.objs.merge_from_cell_result(n_each);
else
    extras = [];
end

end