function mask = isEven(value)
%
%
%   mask = sl.math.isEven(value)
%
%   Non-Integer values will be considered false
%
%   Example:
%   --------
%   sl.math.isEven(1:10)
%   0     1     0     1     0     1     0     1     0     1
%


mask = mod(value,2) == 0;