function output = toLogical(data,default_value)
%
%   output = sl.cellstr.toLogical(data,default_value)
%
%   Example
%   -------
%   data = {'y','n','n'; '','','y'}
%   m = sl.cellstr.toLogical(data,true)
%   
%   m =>
%   2×3 logical array
% 
%    1   0   0
%    1   1   1

output = cellfun(@(x) h__toValue(x,default_value),data);

end

function value = h__toValue(str,default_value)

if isempty(str) || (length(str) == 1 && isnan(str))
    value = default_value;
else
    value = sl.str.toLogical(str);
end

end