function s = groupBy(values,group_id,varargin)
%
%   s = sl.array.groupBy(values,group_id,varargin);
%
%   Input
%   -----
%   values : array or cell array
%   group_id : numeric array or cellstr
%
%   Output
%   ------
%   s : struct
%       .group_id - unique group id values (sorted)
%       .indices
%       .values
%       .n_per_group
%
%   Optional inputs
%   ---------------
%   function : function handle
%       Not yet implemented
%   
%
%   Examples
%   --------
%   s = sl.array.groupBy(1:4,[1 2 1 2]);
%
%   s => struct with fields  (OUT OF DATE)
%    group_id: [1 2]
%      values: {[1 3]  [2 4]}
%
%   Improvements
%   ------------
%   1) Make output a result.
%   2) Provide # of values in each group
%   

in.sorted = true; %false => stable
in.function = '';
in = sl.in.processVarargin(in,varargin);

[u,uI] = sl.array.uniqueWithGroupIndices(group_id);

s.group_id = u;
s.indices = uI;

n_unique = length(u);
temp = cell(1,n_unique);

for i = 1:n_unique
    temp{i} = values(uI{i});
end

s.values = temp;

end