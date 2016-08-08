function data_out = nestedCellsToSingleCellMatrix(data_in)
%
%   
%   data_out = sl.cell.nestedCellsToSingleCellMatrix(data_in)
%
%   data_in{1} = {1 2}
%   data_in{2} = {3 4}
%   
%   data_out = {1 2; 3 4}
%
%   This is primarily designed for regexp outputs with tokens
%
%   Improvements:
%   - remove empty and return indices ...

%NOTE: All of the cells must be of the same length

len = cellfun('length',data_in);
n_elements_in = length(data_in);

if ~all(len == len(1))
    error('Not all inputs are the same length')
end

data_out = cell(n_elements_in,len(1));
for iElement = 1:n_elements_in
   data_out(iElement,:) = data_in{iElement}; 
end