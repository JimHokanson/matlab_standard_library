function [output,s] = toComboMatrix(data,target,dimension_fields,norm_rates,varargin)
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
%   merge_function : function_handle
%   dims : struct
%
%
%
%   Output
%   ------
%   matrix_result :
%   s : structure
%       - fields are names of columns, values are order of indices
%       s.A = [0.5,1]
%       s.B = [2,3]
%
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
%   s.C = [3 5 4 8 9]'
%   data = struct2table(s);
%
%   output = sl.table.toComboMatrix(data,'C',{'A','B'});
%
%   output = sl.table.toComboMatrix(data,'C',{'A','B'},'merge_function','keep_first');
%   output = sl.table.toComboMatrix(data,'C',{'A','B'},'merge_function',@max);
%
%        B  2 3
%        B  2 3
%   A    ---
%  0.5   3 4
%   1    8 5
%   1    8 5
%
%   s = struct;
%   s.A = [1,0.5];
%   output = sl.table.toComboMatrix(data,'C',{'A','B'},'merge_function',@max,'dims',s);
%
%     B  2 3
%     B  2 3
%   A    ---
%   1    8 5   %Note we've forced order of A to be 1 then 0.5, not sorted
%  0.5   3 4
%
%   s = struct;
%   s.A = [1];
%   output = sl.table.toComboMatrix(data,'C',{'A','B'},'merge_function',@max,'dims',s);
%
%     B  2 3
%
%     B  2 3
%   A    ---
%   1    8 5   %Note we've ignored A=0.5
%
%
%
%
%   bc_mat = sl.table.toComboMatrix(data,'bladder_capacity',{'set','fill_rate','expt_id'});

%   see IC from [U,IA,IC] = unique() - use IC to get indices from unique
%
%   fieldnames() - name of fields in structure
%   default value

      temp = data(data.set~=0,:);
 G= findgroups(temp.expt_id);
    temp.position=temp.fill_rate./temp.base_fill_rate;
    for k= 1: length(temp.fill_rate)
        try
            temp.position(k) = find(norm_rates == temp.position(k));
        catch ME
            difference = abs(norm_rates-temp.position(k));
            temp.position(k) =  find(difference == min(difference));
        end
    end

% [U,IA,IC] = unique(temp)
s=struct;
for j = 1:length(dimension_fields)
s.(dimension_fields{j}) = temp.(dimension_fields{j});
end
s.(target) = temp.(target);
% table= struct2table(s);
output_temp= accumarray([temp.set temp.position G],temp.(target));
output_temp(output_temp==0) =NaN;
for i =1 :max(G)
output(i,:) = mean(output_temp(:,:,i),1,'omitnan');
end


in.merge_function = @mean;
in.default_value = NaN;
in.dims = struct(); %empty, no fields overridden
in = sl.in.processVarargin(in,varargin);

if ischar(in.merge_function)
    %    if strcmp(in.merge_function,'keep_first')
    %        in.merge_function = @keep_first;
    %    else
    in.merge_function = str2func(in.merge_function);
    %    end
end

% keyboard

end

function output = keep_first(array)
output = array(1);
end

