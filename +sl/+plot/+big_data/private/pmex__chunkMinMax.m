%x Computes min and maxes over subsets of the input vector
%
%   [mins,maxs,minI,maxI] = pmex__chunkMinMax(data,starts,stops,valid);
%
%   This code removes the need for allocating memory for working with the
%   data subset. It also moves the loop of processing each start and stop
%   into the mex function. Both of these changes tend to speed up the
%   processing time compared to doing the same code in Matlab. One
%   downside is that this function is not multi-threaded. In tests this
%   function tends to be faster than Matlab BUT it is not as fast as it
%   could be.
%
%   TODO: Finish documentation
%
%   Inputs:
%   -------
%
%
%   ChunkMinMax - min and max element of sub-vectors
% [Mins, Maxs] = ChunkMinMax(X, Start, Stop, Valid)
% INPUT:
%   X:     Real double array.
%   Start, Stop: Vectors of type double.
%   Valid: If this is the string 'valid', X cannot contain NaNs and the function
%          runs 10% faster. Optional, default: 'nans'.
% OUTPUT:
%   Mins, Maxs: Minimal and maximal values of the intervals:
%          Data(Start(i):Stop(i))
%          NaN is replied for empty intervals.
%
% NOTES:
% - The values of Start and Stop are assumed to be integers.
% - NaN values in Data are not handled and the reply depends on the compiler.
% - The shape of the inputs is not considered and row vectors are replied.
%
% EXAMPLES:
%   data   = rand(1, 100);
%   starts = [5 10 15 20];  stops = [9 14 19 24];
%   [mins, maxs] = ChunkMinMax(data, starts, stops);
%
% COMPILATION:
%   See help section of ChunkMinMax.c
%   Run uTest_ChunkMinMax to test validity and speed!
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
%         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008/2010
% Assumed Compatibility: higher Matlab versions, Mac, Linux
% Author: Jan Simon, Heidelberg, (C) 2015 matlab.THISYEAR(a)nMINUSsimon.de

