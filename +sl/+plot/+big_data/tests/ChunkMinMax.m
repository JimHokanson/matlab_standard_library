function [out1, out2] = ChunkMinMax(varargin)  %#ok<STOUT>
% ChunkMinMax - min and max element of sub-vectors
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

% $JRev: R-P V:002 Sum:Q0sso0Ayc5dB Date:02-Jan-2015 00:14:05 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\GLMath\ChunkMinMax.m $
% $UnitTest: uTest_MinMaxElem $
% 001: 01-Jan-2015 14:50, First version.

% Initialize: ==================================================================
% This is a dummy code only, which compiles the C-function automatically:
Ok = InstallMex('ChunkMinMax.c');

% Check if NaN detection works:
if Ok
   try
      [mi, ma] = ChunkMinMax(1:2, 1, 2);  %#ok<ASGLU,NASGU>
   catch ME
      if any(strfind(ME.identifyer, ':MachineDep:'))
         fprintf(2, '\n::: Trying a different FP setup:\n');
         if any(strfind(computer, '64'))  % For 64 bit systems:
            Ok = InstallMex('ChunkMinMax.c', {'-DFPCHECK_64'});
         else
            Ok = InstallMex('ChunkMinMax.c', {'-DFPCHECK_64'});
         end

      else
         fprintf(2, '*** Unknown problem.\n');
      end
   end
end

if ~Ok
   error('JSimon:ChunkMinMax:BadCompilation', ...
      'Installation failed. Contact the author.');
end

% Call the unit test:
uTest_ChunkMinMax;

% Do the work: =================================================================
fprintf('\n');
warning(['JSimon:', mfilename, ':FirstCall'], ...
   '\n%s was installed. Future calls are processed by the MEX.\n', mfilename);

% return;
