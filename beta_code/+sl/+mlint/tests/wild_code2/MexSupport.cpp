#include "MexSupport.h"
#include <cstring>
#ifdef RNEL_IS_MEX

#ifdef RNEL_IS_PC
// Attempted to use mx* functions for allocation of new'ed objects.
// Unfortunately, this code causes segfaults in optimized GCC code on Mac.

void *operator new(size_t size) throw(std::bad_alloc)
{
    void* ptr = mxMalloc(size);
    if (!ptr) {
        throw std::bad_alloc();
    }
}

void *operator new(size_t size, const std::nothrow_t&)
{
    return mxMalloc(size);
}

void *operator new[](size_t size) throw(std::bad_alloc)
{
    void* ptr = mxMalloc(size);
    if (!ptr) {
        throw std::bad_alloc();
    }
}

void *operator new[](size_t size, const std::nothrow_t&)
{
    return mxMalloc(size);
}

void operator delete(void *p) throw()
{
    if (p) {
        return mxFree(p);
    }
}
void operator delete[](void *p) throw()
{
    if (p) {
        return mxFree(p);
    }
}
#endif

namespace MexSupport{
    
    void assignToMxArray( bool* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray ) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxUINT8_CLASS;
        rpMxArray = mxCreateLogicalMatrix(0, 0);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    
    void assignToMxArray( MexUInt8* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray ) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxUINT8_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexInt8* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray ) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxINT8_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexUInt16* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxUINT16_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexInt16* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        
        mxClassID classid = mxINT16_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexUInt32* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxUINT32_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexInt32* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxINT32_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow);
        mxSetN( rpMxArray, nCol );
    }
    
    /*
     * void assignToMxArray( long* pArray,
     * unsigned int nRow,
     * unsigned int nCol,
     * mxArray*& rpMxArray) {
     * if( rpMxArray != 0x0 ) {
     * mxDestroyArray(rpMxArray);
     * }
     * mxClassID classid = mxINT32_CLASS;
     * rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
     * mxSetData( rpMxArray, pArray );
     * mxSetM( rpMxArray, nRow );
     * mxSetN( rpMxArray, nCol );
     * }
     */
    
    void assignToMxArray( MexFloat* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxSINGLE_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow );
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexDouble* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxDOUBLE_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow );
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexUInt64* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxUINT64_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow );
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( MexInt64* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if( rpMxArray != 0x0 ) {
            mxDestroyArray(rpMxArray);
        }
        mxClassID classid = mxINT64_CLASS;
        rpMxArray = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        mxSetData( rpMxArray, pArray );
        mxSetM( rpMxArray, nRow );
        mxSetN( rpMxArray, nCol );
    }
    
    void assignToMxArray( const char* datatype,
            void* pArray,
            unsigned int nRow,
            unsigned int nCol,
            mxArray*& rpMxArray) {
        if (strcmp(datatype, "uint8") == 0) {
            assignToMxArray(static_cast<MexUInt8*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "int8") == 0) {
            assignToMxArray(static_cast<MexInt8*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "uint16") == 0) {
            assignToMxArray(static_cast<MexUInt16*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "int16") == 0) {
            assignToMxArray(static_cast<MexInt16*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "uint32") == 0) {
            assignToMxArray(static_cast<MexUInt32*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "int32") == 0) {
            assignToMxArray(static_cast<MexInt32*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "uint64") == 0) {
            assignToMxArray(static_cast<MexUInt64*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "int64") == 0) {
            assignToMxArray(static_cast<MexInt64*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "single") == 0) {
            assignToMxArray(static_cast<MexFloat*>(pArray), nRow, nCol, rpMxArray);
        }
        else if ( strcmp(datatype, "double") == 0) {
            assignToMxArray(static_cast<MexDouble*>(pArray), nRow, nCol, rpMxArray);
        }
        else {
            mexErrMsgTxt("Cannot assign unknown type");
        }
    }
}
#endif