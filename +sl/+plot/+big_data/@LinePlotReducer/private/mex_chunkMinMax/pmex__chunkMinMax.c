// pmex__ChunkMinMax.c
//
// Find min and max element of sub-vectors
// [Mins, Maxs] = ChunkMinMax(X, Start, Stop)
// INPUT:
//   X:    Real double array.
//   Start, Stop: Vectors of type double.
//   Valid: If this is the string 'valid', X cannot contain NaNs and the
//          function runs 10% faster. Optional, default: 'nans'.
// OUTPUT:
//   Mins, Maxs: Minimal and maximal values of the intervals:
//          Data(Start(i):Stop(i))
//          NaN is replied for empty intervals.
//
// NOTES:
// - The values of Start and Stop are assumed to be integers.
// - NaN values in Data are not handled and the reply depends on the compiler.
// - The shape of the inputs is not considered and row vectors are replied.
//
// EXAMPLES:
//   data   = rand(1, 100);
//   starts = [5 10 15 20];  stops = [9 14 19 24];
//   [mins, maxs] = ChunkMinMax(data, starts, stops);
//
// COMPILATION:
//   mex -O pmex__chunkMinMax.c
// If the NaN detection fails, try:
//   mex -O -DFPCHECK_64 ChunkMinMax.c     (or -DFPCHECK_32)
// MSVC 2008/32 profits from these optimization flags in mexopts.bat:
//   OPTIMFLAGS = ... /arch:SSE2 /fp:fast ...
// Linux: Consider c99 comments:
//   mex -O CFLAGS="\$CFLAGS -std=c99" pmex__chunkMinMax.c
// Precompiled Mex files:
//   http://www.n-simon.de/mex
// Run uTest_ChunkMinMax after compiling to test validity and speed!
//
// Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008/2010
// Assumed Compatibility: higher Matlab versions, Mac, Linux
// Author: Jan Simon, Heidelberg, (C) 2015 matlab.THISYEAR(a)nMINUSsimon.de

/*
% $JRev: R-P V:003 Sum:sull9zBW+hqF Date:02-Jan-2015 00:53:32 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\Mex\Source\ChunkMinMax.c $
% $UnitTest: uTest_MinMaxElem $
% 001: 01-Jan-2015 14:50, First version.
*/

#define char16_t UINT16_T

#include "mex.h"

// Machine dependent parameters:
#include "MachineDep.h"

// A header for error messages:
#define ERR_HEAD "*** pmex__chunkMinMax[mex]: "
#define ERR_ID   "JSimon:pmex__ChunkMinMax:"
#define ERROR(id,msg) mexErrMsgIdAndTxt(ERR_ID id, ERR_HEAD msg);

void CoreConsiderNaN(double *Data, mwSize nData,
          double *Start, double *Stop, mwSize nStart,
          double *OutMin, double *OutMax, double *OutMinI, double *OutMaxI);
void CoreIgnoreNaN(double *Data, mwSize nData,
          double *Start, double *Stop, mwSize nStart,
          double *OutMin, double *OutMax, double *OutMinI, double *OutMaxI);

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double  *Data, *Start, *Stop;
  mwSize  nData, nStart, len;
  bool    ConsiderNaN;
  unsigned char *NaNFlag;
  
  // Check type sizes used in the NaN detection once at run-time:
  CHECK_MACHINE_DEP(ERR_ID);
  
  // Check for proper number of arguments:
  if (nrhs < 3 || nrhs > 4) {
    ERROR("BadNArgin", "3 or 4 inputs required.");
  }
  if (nlhs > 4) {
    ERROR("BadNArgout", "1 to 4 outputs allowed.");
  }
  
  Data   = mxGetPr(prhs[0]);
  nData  = mxGetNumberOfElements(prhs[0]);
  Start  = mxGetPr(prhs[1]);
  nStart = mxGetNumberOfElements(prhs[1]);
  Stop   = mxGetPr(prhs[2]);

  // Check types of inputs:
  if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2])) {
    ERROR("BadInputType", "Inputs must be array of type DOUBLE.");
  }
  if (mxIsSparse(prhs[0]) || mxIsComplex(prhs[0])) {
    ERROR("BadDataType", "Data must be non-sparse and real.");
  }
  if (mxGetNumberOfElements(prhs[2]) != nStart) {
    ERROR("BadIntervalSize", "Start and Stop need to be the same size.");
  }
  
  // Parse 4th input:
  ConsiderNaN = true;
  if (nrhs == 4) {
    // Compare first character of 3rd argument:
    if (mxGetNumberOfElements(prhs[3]) != 0) {
      NaNFlag     = (unsigned char *) mxGetData(prhs[3]);
      ConsiderNaN = ((*NaNFlag != 'v') && (*NaNFlag != 'V'));
    }
  }
  
  // Create output and start the processing:
  len     = (nStart == 0) ? 0 : 1;
  plhs[0] = mxCreateDoubleMatrix(len, nStart, mxREAL);
  plhs[1] = mxCreateDoubleMatrix(len, nStart, mxREAL);
  plhs[2] = mxCreateDoubleMatrix(len, nStart, mxREAL);
  plhs[3] = mxCreateDoubleMatrix(len, nStart, mxREAL);
  
  if (ConsiderNaN) {
     CoreConsiderNaN(Data, nData, Start, Stop, nStart,
                     mxGetPr(plhs[0]), mxGetPr(plhs[1]),mxGetPr(plhs[2]), mxGetPr(plhs[3]));
  } else {
     CoreIgnoreNaN(Data, nData, Start, Stop, nStart,
                     mxGetPr(plhs[0]), mxGetPr(plhs[1]),mxGetPr(plhs[2]), mxGetPr(plhs[3]));
  }
  
  return;
}

// =============================================================================
void CoreConsiderNaN(double *Data, mwSize nData,
          double *Start, double *Stop, mwSize nStart,
          double *OutMin, double *OutMax, double *OutMinI, double *OutMaxI)
{
  // Reply NaN for empty intervals or if any element is NaN.
  
  mwSize iStart, iStop, i, j;
  double min, max,
         invalid = mxGetNaN();    // Value for empty intervals
  bool valid = true;
  
  Data = Data - 1;                // 1-based indices in Matlab!
  
  for (i = 0; i < nStart; i++) {
     iStart = (mwSize) Start[i];  // Implicit rounding
     iStop  = (mwSize) Stop[i];
     
     if (iStart <= 0 || iStop > nData) {  // Reject invalid indices
        ERROR("BadInterval", "Interval out of range.");
     }
     
     OutMin[i] = invalid;
     OutMax[i] = invalid;
     if (iStop >= iStart) {
        min = Data[iStart];
        max = min;                // Min==Max for 1st element
        OutMinI[i] = iStart;
        OutMaxI[i] = iStart;
        
        for (j = iStart + 1; j <= iStop; j++) {
           if (ISNAN_D(Data[j])) {
              valid = false;
           } else if (Data[j] < min) {
              min = Data[j];
              OutMinI[i] = j;
           } else if (Data[j] > max) {
              max = Data[j];
              OutMaxI[i] = j;
           }
        }
  
        if (valid) {
           OutMin[i] = min;
           OutMax[i] = max;
        } else {
           valid = true;
        }
     }
  }
  
  return;
}

// =============================================================================
void CoreIgnoreNaN(double *Data, mwSize nData,
          double *Start, double *Stop, mwSize nStart,
          double *OutMin, double *OutMax, double *OutMinI, double *OutMaxI)
{
  // Reply NaN for empty intervals, but do not test for NaN in values.
  
  mwSize iStart, iStop, i, j;
  double min, max,
         invalid = mxGetNaN();    // Value for empty intervals
  
  Data = Data - 1;                // 1-based indices in Matlab!
  
  for (i = 0; i < nStart; i++) {
     iStart = (mwSize) Start[i];  // Implicit rounding
     iStop  = (mwSize) Stop[i];
     
     if (iStart <= 0 || iStop > nData) {  // Reject invalid indices
        ERROR("BadInterval", "Interval out of range.");
     }
     
     if (iStop >= iStart) {
        min = Data[iStart];
        max = min;                // Min==Max for 1st element
        OutMinI[i] = iStart;
        OutMaxI[i] = iStart;
        
        for (j = iStart + 1; j <= iStop; j++) {
           if (Data[j] < min) {
              min = Data[j];
              OutMinI[i] = j;
           } else if (Data[j] > max) {
              max = Data[j];
              OutMaxI[i] = j;
           }
        }
  
        OutMin[i] = min;
        OutMax[i] = max;
     } else {
        OutMin[i] = invalid;
        OutMax[i] = invalid;
     }
  }
  
  return;
}
