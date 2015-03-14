function values = roundToOdd(values,varargin)
%
%   rounded_values = sl.math.roundToOdd(values,varargin);
%
%   Examples:
%   ---------
%   values = [1.5 2.2 3.3 4.8 5.3 11.3];
%   rounded_values = sl.math.roundToOdd(values)
%   rounded_values  => 1     3     3     5     5    11

in.force_evens_up = true;
in = sl.in.processVarargin(in,varargin);

if in.force_evens_up
    values = floor(values);
    mask = sl.math.isEven(values);
    values(mask) = values(mask)+1;
else
    values = ceil(values);
    mask = sl.math.isEven(values);
    values(mask) = values(mask)-1;
end