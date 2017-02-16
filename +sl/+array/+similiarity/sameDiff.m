%
%   flag = sl.array.similiarity.same_diff(data, *tolerance_multiplier)
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
%   tolerance_multiplier: (default 0.00001)
%
%   Example
%   --------
%   d = linspace(0,100,1e7);
%   flag = sl.array.similiarity.sameDiff(d); 
%
%   d = 1:1e7;
%   d(2) = 2.002;
%   flag = sl.array.similiarity.sameDiff(d);
%   %Let's make this less strict ...
%   flag = sl.array.similiarity.sameDiff(d,0.01); 

%{
Compile via:
sl.mex.mexLibFile('sameDiff.c','move_up',true)
%}