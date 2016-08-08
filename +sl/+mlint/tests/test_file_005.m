function test_asdf
%
%   This function is meant to include some errors and warnings
%   for testing sl.mlint.mlint
%
%

y = 1:10;
x = prod(size(y)); %#ok<PSIZE>
temp = my_variable == NaN;

[rhs1 rhs2] = a == b;

error('yo yo yo')