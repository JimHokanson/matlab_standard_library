function same = allSame(data)
%
%   same = sl.array.allSame(data)
%
%   Returns whether all elements in the array are the same as each other.
%
%   Inputs
%   ------
%   data :
%       
%   Outputs
%   -------
%   same : logical
%       Whether or not all elements are the same
%
%   Example
%   -------
%   data = {'test' 'test' 'test'};
%   same = sl.array.similiarity.allExactSame(data)
%
%   data = {'test' 'testing' 'test'};
%   same = sl.array.similiarity.allExactSame(data)
%
%   Possible improvements:
%   ----------------------
%   1) Including a tolerance
%

sl.warning.deprecated('','sl.array.similiarity.allExactSame');

if iscell(data)
    same = all(cellfun(@(x) isequal(data{1},x),data));
else
    same = all(data == data(1));
end

end