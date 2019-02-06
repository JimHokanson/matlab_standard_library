function width = getPrintedIntegerWidth(numeric_value)
%x Returns the width of a number when printed as an integer
%
%   width = sl.numbers.getPrintedIntegerWidth(numeric_value)
%
%   Example
%   -------
%   width = sl.numbers.getPrintedIntegerWidth(1230)
%   width => 4
%
%   width = sl.numbers.getPrintedIntegerWidth(-1230)
%   width => 5


%use log10 instead?
width = length(sprintf('%d',numeric_value));

end