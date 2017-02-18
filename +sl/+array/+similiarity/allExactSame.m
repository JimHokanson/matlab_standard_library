function same = allExactSame(data)
%
%   same = sl.array.similiarity.allExactSame(data)
%
%   Inputs:
%   -------
%   data :
%       
%   Outputs:
%   --------
%   same : logical
%       Whether or not all elements are the same
%

if iscell(data)
    same = all(cellfun(@(x) isequal(data{1},x),data));
else
    same = all(data == data(1));
end


end