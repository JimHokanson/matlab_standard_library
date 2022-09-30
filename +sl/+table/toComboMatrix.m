function [output,s] = toComboMatrix(data,target,dimension_fields,varargin)
%
%   TODO: Rename toComboArray
%
%   [output,s] = toComboMatrix(data,target,dimension_fields,varargin)
%
%   Inputs
%   ------
%   data : table
%   target : string
%       Name of the column to store as the value
%   dimension_fields : cellstr
%       Columns that we will run unique on and use for creating dimensions
%
%   Optional Inputs
%   ---------------
%   merge_function : function_handle, default @mean
%   dims : struct
%       - fields are names of columns
%       - values specifiy the order to use when returning values
%       s.A = [0.5,1]
%       s.B = [3,2]
%
%   Output
%   ------
%   output : nd-array
%       Each dimension stores values based on the input dimension fields
%   s : structure
%       .mapping - structure
%           see dims, same format but what was actually used
%
%   Example
%   -------
%   %Example #1
%   So, if we have:
%   A   B   C
%   ---------
%   0.5 2   3
%   1   3   5
%   0.5 3   4
%   1   2   8
%   1   2   9
%
%   s = struct();
%   s.A = [0.5,1,0.5,1,1]';
%   s.B = [2,3,3,2,2]';
%   s.C = [3 5 4 8 9]';
%   data = struct2table(s);
%
%   output = sl.table.toComboMatrix(data,'C',{'A','B'});
%
%   Returns:
%   
%        B  2   3
%   A    --------
%  0.5      3   4
%   1      8.5  5
%
%   So output(1,1) corresponds to the average value for A=0.5 and B=2
%
%   %Example #2 - combining by @max rather than @mean and forcing
%   %A to be returned as 1,0.5 rather than the default of it being sorted
%   %or 0.5, 1
%
%   s = struct;
%   s.A = [1,0.5];
%   [output2,s2] = sl.table.toComboMatrix(data,'C',{'A','B'},'merge_function',@max,'dims',s);
%
%         B  2 3
%       A    ---
%       1    9 5   %Note we've forced order of A to be 1 then 0.5, not sorted
%      0.5   3 4
%
%   %Note, s2.mapping shows the "row" and "column" names for A and B
%   %indicating that the 1 and 0.5 rows have indeed been swapped as
%   %requested
%
%   %Example #3
%   %Only keep certain entries for a given dimension
%   s = struct;
%   s.A = [1];
%   output3 = sl.table.toComboMatrix(data,'C',{'A','B'},'merge_function',@max,'dims',s);
%
%     B  2 3
%   A    ---
%   1    9 5   %Note we've ignored A=0.5

in.default_value = NaN;
in.dims = struct();
%Missing fields means each will be stored sorted
in.merge_function = @mean;
in = sl.in.processVarargin(in,varargin);

if ischar(in.merge_function)
    switch in.merge_function
        case 'keep_first'
            in.merge_function = @keep_first;
        otherwise
            error('Unrecognized option')
    end
end
%Approach
%------------------------------------
%1) Map each column to an index for that dimension
%
%e.g., takes values for a column like 0.3,0.6,0.3,0.9 and map
%those to indices 1,2,1,3 (default is to use sorted order)
%2) Use accumarray to create the final output by using these indices
%along with a merging function to process the data

n_rows = length(data.(target));
n_cols = length(dimension_fields);

s_map = in.dims; %TODO: Need to make sure this is a struct
if ~isstruct(s_map)
    %fields : column names
    %values : value mapping from 1 to n
    error('Mapping option must contain a structure')
end
sz = zeros(1,n_cols);
subs = zeros(n_rows,n_cols);
delete_mask = false(n_rows,1);
for i = 1:n_cols
    name = dimension_fields{i};
    col_data = data.(name);
    [u,~,ic] = unique(col_data);
    if isfield(s_map,name)
        map = s_map.(name);
        %remap
        %
        % Let's say we have:
        % unique: 2,4,6
        % map: 1, 2, 3, 3.5, 4, 5, 5.5, 6
        %      1  2  3  4    5  6  7    8
        %so we would do:
        %ic of 1 (value 2) gets mapped to 2
        %ic of 2 (value 4) gets mapped to index 4
        ic2 = ic;
        for j = 1:length(u)
            unique_value = u(j);
            new_index =  find(map == unique_value,1);
            if isempty(new_index)
                %don't care, drop
                delete_mask(ic == j) = true;
            else
                %Whereever we have ic == j
                ic2(ic == j) = new_index;
            end
        end
        ic = ic2;
        sz(i) = length(map);
    else
        s_map.(name) = u(:)';
        sz(i) = length(u);
    end
    subs(:,i) = ic;
end

target_values = data.(target);
if any(delete_mask)
   subs(delete_mask,:) = [];
   target_values(delete_mask) = [];
end

s = struct;
s.mapping = s_map;

%accumarray(SUBS,VAL,SZ,FUN,FILLVAL)
output = accumarray(subs, target_values,sz,in.merge_function,in.default_value);
s.counts = accumarray(subs, target_values,sz,@length,0);

end

function output = keep_first(array)
if ~isempty(array)
    output = array(1);
end
end

