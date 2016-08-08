function mask = isOdd(value)
%x Determine if values are odd
%
%   mask = sl.math.isOdd(value)
%
%   Non-Integer values - will not be considered odd
%
%   Example:
%   --------
%   sl.math.isEven(1:10)
%   0     1     0     1     0     1     0     1     0     1
%

%Need == 1, otherwise non-integer values will mostly be true
mask = logical(mod(value,2)==1);