#ifndef MEX_HEADER_SUPPORT_H
#define MEX_HEADER_SUPPORT_H

// This header provides a wrapper for mex.h and matrix.h specifically
// to allow one to switch rapidly between compiling for mex and straight C++ 
// by aliasing printing and memory allocation commands

#ifdef RNEL_IS_MEX | MATLAB_MEX_FILE
    #include "mex.h"
    #include "matrix.h"
#else    
    // alias mex methods to ctdsio
    #define mexPrintf     printf 
    #define mexWarnMsgTxt printf 
        
    #define mxFree    free
    #define mxMalloc  malloc
    #define mxRealloc realloc 
    #define mxCealloc calloc
        
    // these are a bit more involved
    void mexErrMsgTxt(const char*);
    void mexErrMsgIdAndTxt(const char *errorid,const char*,...);
    void mexWarnMsgIdAndTxt(const char *errorid,const char*,...);
        
#endif