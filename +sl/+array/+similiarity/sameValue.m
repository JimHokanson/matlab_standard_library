%
%   flag = sl.array.similiarity.sameValue(data, *absolute_max_difference)
%   
%   This code runs the following equivalent Matlab code:
%
%       diffs = diff(data);
%       flag  = all(diff(diffs) < 0.00001*diffs(1))
%
%   The main advantage of this ciode is that it avoids creating large
%   temporary arrays in memory.
%
%   Inputs
%   ------
%   data: array of doubles
%
%   Optional Inputs
%   ---------------
%   absolute_max_difference: (default: 1e-10)
%
%   Example
%   --------
%   d = ones(1,1e7);
%   flag = sl.array.similiarity.sameValue(d)
%
%   d = ones(1,1e7);
%   d(2) = 1.00001;
%   flag = sl.array.similiarity.sameValue(d)
%   %Let's make this less strict ...
%   flag = sl.array.similiarity.sameValue(d,0.01) 

%{
Compile via:
sl.mex.mexLibFile('sameValue.c','move_up',true)
%}