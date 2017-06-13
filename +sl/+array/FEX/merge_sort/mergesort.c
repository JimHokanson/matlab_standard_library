/**************************************************************************
 * MATLAB mex function mergemex.c
 * Calling syntax:
 * >> C = mergemex(A,B)
 *
 * Purpose: merge two sorted numerical arrays into one.
 *
 * INPUTS
 * - The input arrays A and B must be ascending sorted
 * - They must be vectors and same class
 * OUTPUT
 *   C contains all elements of A and B, ascending sorted
 *   C is the same class and have the length of length(A)+length(B).
 *
 * >> [C idx] = mergemex(A,B)
 * returns idx such that C(idx>0) is equal to A and
 *                       C(idx<0) is equal to B
 *
 *  Compile via:
 *  >> mex -v -O -largeArrayDims mergesort.c
 *
 * Author Bruno Luong <brunoluong@yahoo.com>
 * Date: 03-Oct-2010
 *       31-Oct-2010: speed optimization
 *************************************************************************/

#include "mex.h"
#include "matrix.h"
#include <string.h>

/* Define correct type depending on platform
 * You might have to modify here depending on your compiler */
#if defined(_MSC_VER) || defined(__BORLANDC__)
typedef __int64 int64;
typedef __int32 int32;
typedef __int16 int16;
typedef __int8 int08;
typedef unsigned __int64 uint64;
typedef unsigned __int32 uint32;
typedef unsigned __int16 uint16;
typedef unsigned __int8 uint08;
#else /* LINUX + LCC, CAUTION: not tested by the author */
typedef long long int int64;
typedef long int int32;
typedef short int16;
typedef char int08;
typedef unsigned long long int uint64;
typedef unsigned long int uint32;
typedef unsigned short uint16;
typedef unsigned char uint08;
#endif

// MERGE engine Template
#define MERGE(A, na, B, nb, C, type) { \
    i = j = k = 0; \
    while (1) \
        if ( ((type*)A)[i] <= ((type*)B)[j] ) { \
            ((type*)C)[k++] = ((type*)A)[i++]; \
            if (i>=na) break; \
        } \
        else { \
            ((type*)C)[k++] = ((type*)B)[j++]; \
            if (j>=nb) break; \
        } \
    if (i < na) \
        memcpy(((type*)C)+k, ((type*)A)+i, sizeof(type)*(na-i)); \
    else \
        memcpy(((type*)C)+k, ((type*)B)+j, sizeof(type)*(nb-j)); \
}

// MERGE engine Template with index
#define MERGEIDX(A, na, B, nb, C, type) { \
    i = j = k = 0; \
    while (1) \
        if ( ((type*)A)[i] <= ((type*)B)[j] ) { \
            ((type*)C)[k] = ((type*)A)[i++]; \
            PI[k] = (double)i; \
            k++; \
            if (i>=na) break; \
        } \
        else { \
            ((type*)C)[k] = ((type*)B)[j++]; \
            PI[k] = -(double)j; \
            k++; \
            if (j>=nb) break; \
        } \
    if (i < na) {\
        memcpy(((type*)C)+k, ((type*)A)+i, sizeof(type)*(na-i)); \
        for (l=i; l<na; l++) PI[k++] = (double)(l+1); \
    } \
    else {\
        memcpy(((type*)C)+k, ((type*)B)+j, sizeof(type)*(nb-j)); \
        for (l=j; l<nb; l++) PI[k++] = -(double)(l+1); \
    } \
}

/* Gateway routine mergemex */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    
    const mxArray *A, *B;
    mxClassID ClassID;
    mwIndex m, n, na, nb, nc;
    void *PA, *PB, *PC;
    double *PI;
    mwIndex i, j, k, l;
    
    if (nrhs!=2)
        mexErrMsgTxt("Two input arguments are required.");
    
    /* Check data type of input argument  */   
    A = prhs[0];
    m = (mwIndex)mxGetM(A);
    n = (mwIndex)mxGetN(A);
    if ((m > 1) && (n > 1))
        mexErrMsgTxt("First input argument must be a vector.");
    /* Get the total number elements of A */
    na = m*n;
    
    B = prhs[1];
    m = (mwIndex)mxGetM(B);
    n = (mwIndex)mxGetN(B);
    if ((m > 1) && (n > 1))
        mexErrMsgTxt("Second input argument must be a vector.");
    /* Get the total number elements of A */
    nb = m*n;
    
    nc = na+nb;
    if (m == 1) n = nc; else m = nc;
    
    ClassID = mxGetClassID(A);
    if (ClassID != mxGetClassID(B))
        mexErrMsgTxt("Two inputs must have the same classes.");
    plhs[0] = mxCreateNumericMatrix(m, n, ClassID, mxREAL);
    PA = mxGetData(A);
    PB = mxGetData(B);
    PC = mxGetData(plhs[0]);
    
    if (nlhs<=1) {
        switch (ClassID) {
            case mxDOUBLE_CLASS:
                MERGE(PA, na, PB, nb, PC, double);
                break;
            case mxSINGLE_CLASS:
                MERGE(PA, na, PB, nb, PC, float);
                break;
            case mxINT64_CLASS:
                MERGE(PA, na, PB, nb, PC, int64);
                break;
            case mxUINT64_CLASS:
                MERGE(PA, na, PB, nb, PC,  uint64);
                break;
            case mxINT32_CLASS:
                MERGE(PA, na, PB, nb, PC, int32);
                break;
            case mxUINT32_CLASS:
                MERGE(PA, na, PB, nb, PC, uint32);
                break;
            case mxCHAR_CLASS:
                MERGE(PA, na, PB, nb, PC, uint16);
                break;
            case mxINT16_CLASS:
                MERGE(PA, na, PB, nb, PC, int16);
                break;
            case mxUINT16_CLASS:
                MERGE(PA, na, PB, nb, PC, uint16);
                break;
            case mxLOGICAL_CLASS:
                MERGE(PA, na, PB, nb, PC, uint08);
                break;
            case mxINT8_CLASS:
                MERGE(PA, na, PB, nb, PC, int08);
                break;
            case mxUINT8_CLASS:
                MERGE(PA, na, PB, nb, PC, uint08);
                break;
            default:
                mexErrMsgTxt("MERGEMEX: Class not supported.");
        } /* switch */
    }
    else {
        plhs[1] = mxCreateNumericMatrix(m, n, mxDOUBLE_CLASS, mxREAL);
        PI = mxGetPr(plhs[1]);
        switch (ClassID) {
            case mxDOUBLE_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, double);
                break;
            case mxSINGLE_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, float);
                break;
            case mxINT64_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, int64);
                break;
            case mxUINT64_CLASS:
                MERGEIDX(PA, na, PB, nb, PC,  uint64);
                break;
            case mxINT32_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, int32);
                break;
            case mxUINT32_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, uint32);
                break;
            case mxCHAR_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, uint16);
                break;
            case mxINT16_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, int16);
                break;
            case mxUINT16_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, uint16);
                break;
            case mxLOGICAL_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, uint08);
                break;
            case mxINT8_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, int08);
                break;
            case mxUINT8_CLASS:
                MERGEIDX(PA, na, PB, nb, PC, uint08);
                break;
            default:
                mexErrMsgTxt("MERGEMEX: Class not supported.");
        }
    }
    
    return;
    
} /* mergemex */

