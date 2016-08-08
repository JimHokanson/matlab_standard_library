// MachineDep.h
// This file solves several problems occurring frequently in my Mex files when
// different compilers are used:
// - A faster replacement for Matlab's mxIsNaN() working for DOUBLE and FLOAT:
//   Depending on the compiler different strategies are required to detect NaNs.
//   E.g. the MSVC compiler v2008 with the /fp:fast flag does not reply FALSE
//   for NaN==NaN. Checking the NaN test at compile time must fail, but a test
//   at runt time is cheap, when it is performed once only.
//   Different methods are implemented, which can be controlled by compiler
//   directives:
//     -DFPCHECK_MATLAB: Standard methods of Matlab.
//     -DFPCHECK_32, -DFPCHECK_64: Bit pattern tests with 32 or 64 bit
//                       constants as macro. This is faster than the Mex-API.
//     Default: X!=X is applied to detect NaNs.
// - Case-insensitive string comparison
// - Matlab6.5 does not define mwSize, mwIndex and mwSignedIndex.
// - The LCC compiler shipped with older Matlab versions fails for int64_T.
//
// Insert this in the header section of the main file:
//   #include "MachineDep.h"
// Insert this in the main function - use a string for a meaningful message in
// case of errors:
//   CHECK_MACHINE_DEP("CallerName");
//
// Defined macros:
//   INSNAN_D:   TRUE for NaN of type double.
//   ISFINITE_D: TRUE if argument is +-Inf.
//   INSNAN_F, ISFINITE_F: Same for FLOAT.
//   CHECK_MACHINE_DEP: Code to perform a short runtime test.
//   mwSize, mwIndex, mwSignedIndex: Defined as int32_T for old Matlab versions
//   STRNCMP, STRNCMP_I: C-functions for string comparison
//
// Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008/2010
// Assumed Compatibility: higher Matlab versions, Mac, Linux
// Author: Jan Simon, Heidelberg, (C) 2013-2015 j@n-simon.de

/*
% $JRev: R-j V:009 Sum:tTz53vo1jEmC Date:02-Jan-2015 00:14:13 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_MachineDep $
% $File: Tools\Mex\Source\MachineDep.h $
% History:
% 001: 15-Oct-2013 08:45, First version.
*/

#ifndef _MACHINE_DEP_H_
#define _MACHINE_DEP_H_

// Assume 32 bit addressing for Matlab 6.5: ------------------------------------
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define mwSignedIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

// Dependency to endianess: ----------------------------------------------------
#if defined(_BIG_ENDIAN) && !defined(_LITTLE_ENDIAN)
#  define HIGH_32(a) (*(int32_T *) &(a))
#  define LOW_32(a)  (*(1 + (int32_T * ) &(a)))
#else   // Default: Little endian machine
#  define HIGH_32(a) (*(1 + (int32_T * ) &(a)))
#  define LOW_32(a)  (*(int32_T *) &(a))
#endif

// Assume 32 bit addressing for Matlab 6.5: ------------------------------------
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

// 64 bit constants: -----------------------------------------------------------
#if defined(__BORLANDC__)         // No "LL" for BCC 5.5
#  define FIN_MASK   (uint64_T) 0x7ff0000000000000UL
#  define NAN_MASK   (uint64_T) 0x000fffffffffffffUL
#  define ZERO64     (uint64_T) 0x0UL
#  define INTEGER_64 uint64_T

#elif defined(__LCC__)
// LCC v2.4 and v3.8 have problems with int64_T, which I do not understand.
// Using the equivalent LONG LONG instead works well, but slower than DOUBLEs
// inspite of the additional tests for NaN!
#  define INTEGER_64 long long    // Signed!
#  define int64_T    long long    // Should be defined in tmwtypes.h already?!
#  define FIN_MASK   0x7ff0000000000000LL
#  define NAN_MASK   0x000fffffffffffffLL
#  define ZERO64     0x0LL

#else  // Default:
#  define FIN_MASK   0x7ff0000000000000ULL
#  define NAN_MASK   0x000fffffffffffffULL
#  define INTEGER_64 uint64_T
#  define ZERO64     0x0ULL
#endif

// Check for NaN and INF: ------------------------------------------------------
// Different methods to detect NaNs are called depending on compile flags:
// 1. Default:         a != a is TURE for NaNs only
// 2. -FPCHECK_MATLAB: mxIsNaN, built-in but slow
// 3. -FPCHECK_32:     Bit pattern matching in 32 bit chunks. Use -D_BIG_ENDIAN
//                     on demand in addition.
// 4. -FPCHECK_64:     Default, match pattern in 64 bit block.
// The validity is checked at runtime also.

#if defined(__LCC__) || defined(__WATCOMC__) || defined(__BORLANDC__)
#  define FPCHECK_32
#endif

// DOUBLE:
#if defined(FPCHECK_MATLAB)  // Original Matlab test:
#  define ISNAN_D(a)     mxIsNaN(a)
#  define ISFINITE_D(a)  mxIsFinite(a)

#elif defined(FPCHECK_32)    // Faster test of bit pattern on 32 bit machines:
#  define ISNAN_D(a)    (((HIGH_32(a) & 0x7ff00000UL) == 0x7ff00000L) && \
                         ((HIGH_32(a) & 0x000fffffUL) || \
                          (LOW_32(a)  & 0xffffffffUL)) )
#  define ISFINITE_D(a) (((HIGH_32(a) & 0x7ff00000UL) != 0x7ff00000L)

#elif defined(FPCHECK_64)    // As fast as 32 bit, independent from endianess:
// 64 bit constants to compare logicals in blocks of 8 elements:
#  define ISNAN_D(a)   (((*(INTEGER_64 *) &(a) & FIN_MASK) == FIN_MASK) && \
                        ((*(INTEGER_64 *) &(a) & NAN_MASK) != ZERO64))
#  define ISFINITE_D(a) ((*(INTEGER_64 *) &(a) & FIN_MASK) != FIN_MASK)

#else                        // Default: NaN != NaN replies TRUE, fastest:
#  define ISNAN_D(a)    ((a) != (a))
#  define ISFINITE_D(a) ((*(INTEGER_64 *) &(a) & FIN_MASK) != FIN_MASK)
#endif

// FLOAT:
// No mxIsNaN for float (_isnanf for MSVC, ISNAN_F for LCC, not defined in
// Open Watcom 1.8 and BCC 5.5):
#if defined(FPCHECK_32) || defined(FPCHECK_64)
#  define ISNAN_F(a)  (((*(int32_T *) &(a) & 0x7f800000UL) == 0x7f800000UL) && \
                       ((*(int32_T *) &(a) & 0x007fffffUL) != 0x00000000UL))
#else
#  define ISNAN_F(a)  ((a) != (a))
#endif
#define ISFINITE_F(a) (((*(int32_T *) &(a) & 0x7f800000UL) != 0x7f800000UL)

// String comparison: ----------------------------------------------------------
// strncmpi, strnicmp, _strnicmp, strncasecmp, ...
#include <string.h>

#if defined(__WINDOWS__) || defined(WIN32) || defined(_WIN32) || defined(_WIN64)
#  if defined(__LCC__)
#    define STRNCMP_I strnicmp
#    define STRNCMP   strncmp
#  else
#    define STRNCMP_I _strnicmp
#    define STRNCMP   _strncmp
#  endif
#else  // Mac and Linux:
#  define STRNCMP_I strncasecmp
#endif

// Code to test the function at runtime:
static int CheckMachineDep_flag = 1;
#define CHECK_MACHINE_DEP(Caller) \
   if (CheckMachineDep_flag) {CheckMachineDep(Caller);}

// Prototypes: -----------------------------------------------------------------
void CheckMachineDep(const char* Caller);

// =============================================================================
void CheckMachineDep(const char* Caller) {
  // Check type sizes and validity of NaN detection at run-time.
  // A check during compile time is less powerful, because the pre-processor
  // need not use the same data types as the compiler.
  // Checking at run-time wastes a micro-second per Matlab session only.
  
  // I know that a header file should not contain functions definitions, but I
  // want to reduce the number of files submitted to the FileExchange.
   
  double d_nan, d_inf;
  float  f_nan, f_inf;
  
  // If this failes for any mysterious reasons, ISNAN_D can be fixed by
  // compiling with -DFPCHECK_MATLAB, but I do not have a workaround for
  // ISNAN_F!
  if (sizeof(int32_T) != 4 || sizeof(float) != 4 || sizeof(double) != 8 ||
      sizeof(INTEGER_64) != 8) {
     mexErrMsgIdAndTxt("JSimon:MachineDep:BadTypeSize",
                       "%s: Sizes of types do not match requirements.", Caller);
  }
  
  // Check proper recognition of values:
  d_nan = mxGetNaN();
  d_inf = mxGetInf();
  f_nan = (float) d_nan;
  f_inf = (float) d_inf;
  
  if (!ISNAN_D(d_nan) || ISNAN_D(d_inf)|| !ISNAN_F(f_nan) || ISNAN_F(f_inf)) {
     mexPrintf("Debug info: "
           "isnan_d(nan)=%i isnan_d(inf)=%i isnan_f(nan)=%i isnan_f(inf)=%i\n",
           ISNAN_D(d_nan), ISNAN_D(d_inf), ISNAN_F(f_nan), ISNAN_F(f_inf));
     mexErrMsgIdAndTxt("JSimon:MachineDep:NaNFailed",
           "%s: Test for NaNs failed. Try to recompile with flag:\n"
           "  -DFPCHECK_64 or \n"
           "  -DFPCHECK_32  (and -D_BIG_ENDIAN on demand) or\n"
           "  -DFPCHECK_MATLAB\n", Caller);
  }
  
  // Disable flag for testing:
  CheckMachineDep_flag = 0;
  
  return;
}
#endif  // _MACHINE_DEP_H_
