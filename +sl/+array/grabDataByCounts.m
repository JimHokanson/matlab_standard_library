function data_cell_array = grabDataByCounts(data,counts)
%grabDataByCounts  Grabs data in sets by the size of counts 
%
%   data_cell_array = sl.array.grabDataByCounts(data,counts)
%
%   This is similar to mat2cell, which is not used in this implementation
%   but which could be used to produce the same output ...
%
%   See Also:
%   mat2cell 

if length(data) ~= sum(counts)
    error('Data is missing')
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