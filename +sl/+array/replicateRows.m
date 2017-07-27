function output = replicateRows(input_matrix,n)
%x Replicates rows internally
%
%   out = sl.array.replicateRows(array,n)
%   
%   Replicates rows internally. This is meant to be as opposed to repmat
%   which replicates externally.
%
%   Inputs
%   ------
%   input_matrix : array or cell
%   n : 
%
%   Outputs
%   -------
%   output : 
%
%   Examples
%   --------
%   array = reshape(1:12,4,3)';
%     %  1     2     3     4
%     %  5     6     7     8
%     %  9    10    11    12
%   out = sl.array.replicateRows(array,3);
%   out => 
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      5     6     7     8
%      5     6     7     8
%      5     6     7     8
%      9    10    11    12
%      9    10    11    12
%      9    10    11    12

sz = size(input_matrix);
sz(1) = sz(1)*n;

if iscell(input_matrix)
    output = cell(sz);
else 
    output = zeros(sz,'like',input_matrix);
end

for i = 1:n
    output(i:n:end,:) = input_matrix;
end


end

function test_code()

array = reshape(1:12,4,3)';

%      1     2     3     4
%      5     6     7     8
%      9    10    11    12



out = sl.array.replicateRows(array,3);

end