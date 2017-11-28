function mask = isIntegerValue(data)
%
%   Tests wheter floating point value is an integer
%   - 3.00000 => yes
%   - 3.00000000001 => no
%
%   mask = sl.numbers.isIntegerValue(data);
%
%   Improvements
%   -------------
%   eps?

%abs(round(X) - X) <= sqrt(eps(X))

mask = data == round(data);
end