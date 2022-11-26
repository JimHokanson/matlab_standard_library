function t = toTable(values,name,dimension_names,dimension_values)
%
%   t = sl.matrix.toTable(values,name,dimension_names,dimension_values)
%
%   See Also
%   --------
%   sl.table.toComboMatrix
%
%   Improvement
%   -----------
%   1. Could support variable order of populating rows. Current behavior
%   starts with last variable
%   2. Support null value row dropping

n_values = numel(values);

sz = size(values);
n_dims = length(sz);

%all_dim_indices = zeros(n_values,n_dims);

%dim 1, count every value
%1:4 1:4 1:4
%

rep_size = 1;
s = struct();
for i = 1:n_dims
    %1st, replicate within values
    n_elements_dim_i = sz(i);
    repped_values = repelem((1:n_elements_dim_i)',rep_size);
    rep_size = rep_size*n_elements_dim_i;
    dim_indices = repmat(repped_values,n_values/length(repped_values),1);
    temp = dimension_values{i}(:);
    s.(dimension_names{i}) = temp(dim_indices);
end

temp = values(1:n_values);
s.(name) = temp(:);

t = struct2table(s);

end