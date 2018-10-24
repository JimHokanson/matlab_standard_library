function [data,extras] = mergeFromCells(cell_data)
%x Create a vector of data from cells which contain vectors
%
%   [data,extras] = sl.array.mergeFromCells(cell_data)
%
%   Note this really helps with computing the extras output
%   which includes the size of each cell and ids of each output
%   mapped to the input
%
%   Inputs
%   ------
%   cell_data : cell array of vectors
%
%   Outputs
%   -------
%   data : vector
%   extras : sl.array.objs.merge_from_cell_result
%
%   Examples
%   --------
%   cell_data = {1 2:3 4:7};
%   [data,extras] = sl.array.mergeFromCells(cell_data)
%     % data =
%     %      1     2     3     4     5     6     7
%     % 
%     % extras = 
%     %   merge_from_cell_result with properties:
%     % 
%     %     n_each: [1 2 4]
%     %     labels: [1 2 2 3 3 3 3]

n_each = cellfun('length',cell_data);
n_each2 = cellfun('prodofsize',cell_data);

if ~isequal(n_each,n_each2)
    error('Not all inputs are vectors')
end

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