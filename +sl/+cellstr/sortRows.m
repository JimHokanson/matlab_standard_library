function [sorted_data,I] = sortRows(data,column_order)
%sortRows  Sorts cell array rows by given column order
%
%   This function currently only works with cell array of strings ...
%
%   [sorted_data,I] = sl.cellstr.sortRows(data,*column_order)
%
%   OUTPUTS
%   =======================================================================
%   sorted_data : the sorted cell array
%   I           : indices of the original in the new array
%
%   INPUTS
%   =======================================================================
%   data : cell array of strings to sort
%   column_order : (default sorts by column 1 to column n), the column order
%               to sort by (see input in function sortrows)
%
%   See Also: 
%   sortrows

if nargin == 1
    column_order = [];
end

%Here we translate strings to an number set
%Importantly, since unique returns things sorted, i.e. a,b,c,d
%Then the numbers output in temp_I will also be relatively sorted
%
%   Put another way, it is impossible to have
%   'a_string'
%   'b_string'   
%   and when sorted, have 1 point to 'b_string' and 2 point to 'a_string'
[~,~,temp_I] = unique(data(:));

%Once our strings are numbers, then just call sortrows
temp_I_reshaped = reshape(temp_I,size(data));

if isempty(column_order)
    [~,I] = sortrows(temp_I_reshaped);
else
    [~,I] = sortrows(temp_I_reshaped,column_order);
end

sorted_data = data(I,:);

end

function helper__examples()

data = {'a' 'b' 'c'; 'a' 'b' 'd'; 'd' 'e' 'f'; 'a' 'c' 'b'};

[sorted_data,I] = sl.cellstr.sortRows(data);

end