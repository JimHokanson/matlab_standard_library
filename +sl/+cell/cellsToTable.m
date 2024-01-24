function [t,s] = cellsToTable(cell_data,varargin)
%
%   [t,s] = cellsToTable(cell_data,varargin)
%
%   Converts cells with numbers, where each cell is a different group
%   to a two-column table where the first column includes all of the data
%   and the second cell includes which cell the data came from ("group_id")
%
%   Inputs
%   ------
%   cell_data : cell array of numeric arrays
%
%   Optional Inputs
%   ---------------
%   group_names :
%       Pass this in if you want to use a different value than 1,2,3
%
%   Outputs
%   -------
%   t : table
%       .data - values
%       .group_id - ID linking various data values together
%
%   s : struct
%       Extra stuff. Format may change over time ....
%
%
%   Example
%   -------
%   %        1          2         3  <- index of the cell -> "group_id"
%   C = {[1; 2; 3], [4; 5], [6; 7; 8; 9]};
%   T = sl.cell.cellsToTable(C);
%   disp(T);
%   boxplot(T.data,T.group_id);
%
%    data    group_id
%    ____    ________
%     1         1    
%     2         1    
%     3         1    
%     4         2    
%     5         2    
%     6         3    
%     7         3    
%     8         3    
%     9         3 
%

in.group_names = {};
in = sl.in.processVarargin(in,varargin);

n_cells = length(cell_data);
if isempty(in.group_names)
   in.group_names = num2cell(1:n_cells);
end

% Initialize empty arrays for data and groupID
data = [];
group_ids = [];

s = struct;
s.n_elements = cellfun('length',cell_data);


for idx = 1:n_cells
    current_cell = cell_data{idx}; % Extract data from current cell
    
    % Append the data to the data array
    data = [data; current_cell(:)];
    
    % Append the group ID (index of the cell in the original array)
    
    
    group_name = in.group_names(idx);
    if isnumeric(group_name{1})
        group_name = group_name{1};
    end
    group_ids = [group_ids; repmat(group_name,length(current_cell),1)];
end

% Convert arrays to a table
t = table(data, group_ids, 'VariableNames', {'data', 'group_id'});


end

%{
C = {[1; 2; 3], [4; 5], [6; 7; 8; 9]};
T = sl.cell.cellsToTable(C);
disp(T);
boxplot(T.data,T.group_id);
%}