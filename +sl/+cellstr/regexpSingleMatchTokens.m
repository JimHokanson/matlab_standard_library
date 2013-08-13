function [output,is_matched] = regexpSingleMatchTokens(data_in,pattern)
%
%
%   [output,is_matched] = sl.cellstr.regexpSingleMatchTokens(data_in,pattern)
%   

if ischar(data_in)
    error('This function is designed for cell strings') %??? Move to cellstr?
end

%??? Provide length as input????

temp = regexp(data_in,pattern,'tokens','once');

len = cellfun('length',temp);

is_matched = len ~= 0;

output_len = max(len);

%TODO: Don't iterate over non-matches
%Do this assignment on the output
temp(~is_matched) = {repmat({''},1,output_len)};

n_rows = length(data_in);

output = cell(n_rows,output_len);

for iRow = 1:n_rows
   output(iRow,:) = temp{iRow}; 
end

