function data_cell_array = toCellArrayByCounts(data,counts)
%toCellArrayByCounts  Grabs data in sets by the size of counts 
%
%   data_cell_array = sl.array.toCellArrayByCounts(data,counts)
%
%   This is similar to mat2cell, which is not used in this implementation
%   but which could be used to produce the same output.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Include differential in error message regarding which input
%   has less than the other (i.e. how to remedy the problem)
%
%   See Also:
%   sl.array.genFromCounts
%   mat2cell 
%
%   I'm not a really big fan of the name of this function ...

l_data   = length(data);
s_counts = sum(counts);
if l_data ~= s_counts
    error('Data is missing, data length: %d, sum of counts: %d',l_data,s_counts)
end

n_groups        = length(counts);
data_cell_array = cell(1,n_groups);

cur_end_index  = 0;
for iGroup = 1:n_groups
    cur_start_index = cur_end_index + 1;
    cur_end_index   = cur_start_index + counts(iGroup) - 1;
    data_cell_array{iGroup} = data(cur_start_index:cur_end_index);
end

end

function helper__examples() %#ok<DEFNU>

data   = 1:10;
counts = [2 3 5]; 
data_cell_array = sl.array.toCellArrayByCounts(data,counts); %#ok<NASGU>
%data_cell_array => {[1 2] [3 4 5] [6 7 8 9 10]}


end