function same = allSame(data)
%
%   same = sl.array.allSame(data)
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
%   Possible improvements:
%   ----------------------
%   1) Including a tolerance
%

if iscell(data)
    same = all(cellfun(@(x) isequal(data{1},x),data));
else
    same = all(data == data(1));
end

end