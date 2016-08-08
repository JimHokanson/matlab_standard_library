function uTest_ChunkMinMax(doSpeed)
% Automatic test: ChunkMinMax
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% uTest_ChunkMinMax(doSpeed)
% INPUT:
%   doSpeed: If TRUE, the speed is tested. Optional.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2015 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R-p V:001 Sum:tNFt40pAYYL1 Date:01-Jan-2015 23:46:54 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\UnitTests_\uTest_ChunkMinMax.m $
% History:
% 001: 01-Jan-2015 14:57, First version.

% Initialize: ==================================================================
ErrID = ['JSimon:', mfilename, ':Failed'];

disp(['== Test ChunkMinMax:  ', datestr(now, 0)]);
disp(['Version: ', which('ChunkMinMax'), char(10)]);
pause(0.01);

if nargin == 0
   doSpeed = true;
end

if doSpeed
   nRandTest = 5000;
   nRandDisp = 500;   % Display dots
else
   nRandTest = 500;
   nRandDisp = 100;
end

% Known answer tests: ----------------------------------------------------------
disp('Known answer tests:');

validC = {'valid', 'invalid'};
for valid = 1:2
   validFlag = validC{valid};
   
   [mi, ma] = ChunkMinMax([], [], [], validFlag);
   if ~isempty(mi) || ~isempty(ma)
      error(ErrID, ['*** ', mfilename, ': Failed for empty input.']);
   end
   
   [mi, ma] = ChunkMinMax(1:10, [], [], validFlag);
   if ~isempty(mi) || ~isempty(ma)
      error(ErrID, ['*** ', mfilename, ': Failed for empty intervals.']);
   end
   
   [mi, ma] = ChunkMinMax(2:10, 1, 1, validFlag);
   if ~isequal(mi, 2) || ~isequal(ma, 2)
      error(ErrID, ['*** ', mfilename, ': Failed for 1st element of 2:10.']);
   end
   
   [mi, ma] = ChunkMinMax(2:10, 1, 3, validFlag);
   if ~isequal(mi, 2) || ~isequal(ma, 4)
      error(ErrID, ['*** ', mfilename, ': Failed for 1:3 element of 2:10.']);
   end
   
   [mi, ma] = ChunkMinMax(10:-1:1, 2, 3, validFlag);
   if ~isequal(mi, 8) || ~isequal(ma, 9)
      error(ErrID, ['*** ', mfilename, ': Failed for 2:3 element of 10:-1:1.']);
   end
   
   [mi, ma] = ChunkMinMax(10:-1:1, [2, 3], [3, 2], validFlag);
   if mi(1) ~= 8 || ma(1) ~= 9 || ~isnan(mi(2)) || ~isnan(ma(2))
      error(ErrID, ['*** ', mfilename, ': Failed for [2,3],[3,2] of 10:-1:1.']);
   end
end

[mi, ma] = ChunkMinMax([1,NaN,2], 1, 3);
if ~isnan(mi) || ~isnan(ma)
   error(ErrID, ['*** ', mfilename, ': Failed for NaN.']);
end

[mi, ma] = ChunkMinMax([1,NaN,2,3], [1, 3], [3, 4]);
if ~isnan(mi(1)) || ~isnan(ma(1)) || mi(2) ~= 2 || ma(2) ~= 3
   error(ErrID, ['*** ', mfilename, ': Failed for NaN in 1 interval.']);
end

fprintf('  ok\n\n');

% Random data tests: -----------------------------------------------------------
fprintf('Random test data:\n  ');
Data = rand(1, 100);
for iTest = 1:nRandTest
   if mod(iTest, nRandDisp) == 0
      fprintf('.');
   end
   
   Len    = ceil(rand * 1000);   % No RANDI for Matlab 6.5
   xStart = ceil(rand(1, Len) * 100);
   xStop  = ceil(rand(1, Len) * 100);
   Start  = min(xStart, xStop);
   Stop   = max(xStart, xStop);
   valid  = validC{ceil(rand + 0.5)};
   
   [mi_X, ma_X] = ChunkMinMax(Data, Start, Stop, valid);
   [mi_M, ma_M] = localM(Data, Start, Stop);
   if ~isequal(mi_X, mi_M) || ~isequal(ma_X, ma_M)
      fprintf('\n');
      error(ErrID, ['*** ', mfilename, ': Bad reply.']);
   end
end
fprintf(' ok\n\n');

% Bad input tests: -------------------------------------------------------------
fprintf('Bad input data test:\n');
tooLazy = false;
try                                   %#ok<*TRYNC>
   [mi, ma] = ChunkMinMax([], 1, 2);  %#ok<*ASGLU,*NASGU>
   tooLazy  = true;
end
if tooLazy
   error(ErrID, ['*** ', mfilename, ': Interval out of range accepted (1).']);
end

try
   [mi, ma] = ChunkMinMax(1, 1, 2);
   tooLazy  = true;
end
if tooLazy
   error(ErrID, ['*** ', mfilename, ': Interval out of range accepted (2).']);
end

try
   [mi, ma] = ChunkMinMax(1:10, 0, 1);
   tooLazy  = true;
end
if tooLazy
   error(ErrID, ['*** ', mfilename, ': Interval out of range accepted (2).']);
end

try
   [mi, ma] = ChunkMinMax(int32(1:10), 0, 1);
   tooLazy  = true;
end
if tooLazy
   error(ErrID, ['*** ', mfilename, ': Bad input type accepted (1).']);
end

try
   [mi, ma] = ChunkMinMax(1:10, uint64(0), uint64(1));
   tooLazy  = true;
end
if tooLazy
   error(ErrID, ['*** ', mfilename, ': Bad input type accepted (2).']);
end
fprintf('  ok\n');

% Speed test: ------------------------------------------------------------------
fprintf('\nSpeed tests:\n');

% Find a suiting number of loops:
if ~doSpeed
   disp('  2 loops (timings not reliable!)');
   xLoop = 2;
   mLoop = 2;
end

Data = rand(1, 1e7);
fprintf('                         Matlab     Mex\n');
for lenChunk = [10, 100, 1000, 10000, 100000]
   fprintf('  Chunk length: %5d\n', lenChunk);
   for nChunk = [1e1, 1e2, 1e3, 1e4, 1e5]
      Start = ceil(rand(1, nChunk) * (1e6 - lenChunk));
      Stop  = Start + lenChunk;
      
      if doSpeed
         iLoop     = 0;
         startTime = cputime;
         while cputime - startTime < 1.0
            [mi, ma] = ChunkMinMax(Data, Start, Stop);
            clear('mi', 'ma');
            iLoop = iLoop + 1;
         end
         xLoop = 100 * ceil(iLoop / ((cputime - startTime) * 100));
         mLoop = max(5, ceil(xLoop / 100));
         % fprintf('  %d loops on this machine.\n', xLoop);
      end
      
      tic;
      for k = 1:xLoop
         [mi, ma] = ChunkMinMax(Data, Start, Stop);
         clear('mi', 'ma');
      end
      xTime = 1000 * toc / xLoop;
      
      tic;
      for k = 1:mLoop
         [mi, ma] = localM(Data, Start, Stop);
         clear('mi', 'ma');
      end
      mTime = 1000 * toc / mLoop;
      
      fprintf('    Intervals: %6d  %8.3f  %8.3f  %5.1f%%\n', ...
         nChunk, mTime, xTime, 100*xTime/mTime);
   end
end
fprintf('                        ms/call   ms/call\n');

% Speed without testing for NaNs: ----------------------------------------------
fprintf('\n  Omit test for NaN values:\n');
fprintf('                       NaN-test    no NaN-test\n');
lenChunk = 100;
nChunk   = 1e4;
fprintf('  Chunk length: %5d\n', lenChunk);
Start = ceil(rand(1, nChunk) * (1e6 - lenChunk));
Stop  = Start + lenChunk;

if doSpeed
   iLoop     = 0;
   startTime = cputime;
   while cputime - startTime < 1.0
      [mi, ma] = ChunkMinMax(Data, Start, Stop);
      clear('mi', 'ma');
      iLoop = iLoop + 1;
   end
   xLoop = 100 * ceil(iLoop / ((cputime - startTime) * 100));
   % fprintf('  %d loops on this machine.\n', xLoop);
end

tic;
for k = 1:xLoop
   [mi, ma] = ChunkMinMax(Data, Start, Stop);
   clear('mi', 'ma');
end
xTime = 1000 * toc / xLoop;

tic;
for k = 1:xLoop
   [mi, ma] = ChunkMinMax(Data, Start, Stop, 'valid');
   clear('mi', 'ma');
end
xTime2 = 1000 * toc / xLoop;

fprintf('    Intervals: %6d  %8.3f  %8.3f  %5.1f%%\n', ...
   nChunk, xTime, xTime2, 100*xTime2/xTime);
fprintf('                        ms/call   ms/call\n');

% Good bye: --------------------------------------------------------------------
fprintf('\nChunkMinMax passed the tests.\n');
% return;


% ******************************************************************************
function [MinS, MaxS] = localM(data, start, stop)
% Find min and max finite element over one or several arrays

% Do the work: =================================================================
n    = numel(start);
MinS = zeros(1, n);
MaxS = zeros(1, n);
for k = 1:n
   data_subset = data(start(k):stop(k));
   MinS(k)     = min(data_subset);
   MaxS(k)     = max(data_subset);
end
 
% return;
