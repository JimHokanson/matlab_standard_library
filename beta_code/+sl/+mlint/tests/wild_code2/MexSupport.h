
#ifndef MEX_SUPPORT_H
#define MEX_SUPPORT_H
#ifdef RNEL_IS_MEX
#include "matrix.h"
#include "mex.h"
#include "MexDataTypes.h"

// Assertions - <cassert>'s assert() crashes matlab with SIGABRT
#define assert(b) (((b) ? (void)0 : mexErrMsgTxt( __FILE__ " Assertion failed:" #b)))

#ifdef RNEL_IS_PC
#include <new>
void* operator new(size_t size) throw(std::bad_alloc);
void* operator new(size_t size, const std::nothrow_t&);
void* operator new[](size_t size) throw(std::bad_alloc);
void* operator new[](size_t size, const std::nothrow_t&);
 
void operator delete(void *p) throw();
void operator delete[](void *p) throw();
#endif

namespace  MexSupport {
    
    inline int sub2ind(int nRow, int nCol, int iiRow, int iiCol)
    {
        return iiRow+iiCol*nRow;
    }
    
    // assigns, -not- copies, a pointer to an array
    // This is the faster way to get data into matlab, so long as it has been formatted
    // correctly
    void assignToMxArray( bool* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray );
    
    void assignToMxArray( MexInt8* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexUInt8* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexInt16* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexUInt16* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexInt32* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexUInt32* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexFloat* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexDouble* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexUInt64* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( MexInt64* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
    
    void assignToMxArray( const char* datatype,
            void* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray);
};
#else
// The folowing adds support for rapidly debugging in native C++ and is
// disabled for mex compilation
#include <cstdio>
// print
#define mexPrintf printf
#define mexWarnMsgTxt printf
// memory 
#define mxMalloc malloc
#define mxRealloc realloc
#define mxFree free
// errors
#include <exception>
#define  mexErrMsgTxt std::exception
#include "MexDataTypes.h"
#endif
#endif
