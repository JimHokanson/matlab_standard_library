
#include "mex.h"
#include "matrix.h"
#include <algorithm>
#include <cmath>
#include "MexSupport.h"
#include "MexAlgorithmSupport.h"
#include "MexDataTypes.h"

using namespace std;
using namespace MexSupport;
void print_usage();


void mexFunction(int nlhs, mxArray** plhs, int nrhs, const mxArray * prhs[]) {
    if(nrhs < 3) {
        print_usage();
        return;
    }
    
    double* pA =  mxGetPr(prhs[0]);
    double* pB =  mxGetPr(prhs[1]);
    
    double tol    = *mxGetPr(prhs[2]);
    bool one_sided = false;
    int tol_sign  = 1;
    if( nrhs > 3 ) {
        one_sided	 = *mxGetLogicals(prhs[3]);
        tol_sign = (tol > 0 ? 1 : -1);
        tol			 = fabs(tol);
    }
    
    int nA = mxGetNumberOfElements(prhs[0]);
    int nB = mxGetNumberOfElements(prhs[1]);
    
    // sort inputs. requires deep copy of input

    double *pA_sort(0x0);
    MexUInt32 *pA_idx(0x0);
    sort_with_index(pA,nA,pA_sort,pA_idx);
    
    double *pB_sort(0x0);
    MexUInt32 *pB_idx(0x0);
    sort_with_index(pB,nB,pB_sort,pB_idx);
    
    bool* pMask  = (bool*)mxMalloc(sizeof(bool)*nA);
    double* pIdx = (double*)mxMalloc(sizeof(double)*nA);
    
    int iiB    = 0;
    int last_break = 0;
    double err(0.0);
    
    bool match(false);
    for(int iiA = 0; iiA < nA; iiA++) {
        match = false;
        // The following loop iterates until either a match is found or the
        // current element of A is significantly less than that of B. This
        // relies on A & B having been sorted, see above.
        for(iiB = last_break; iiB < nB; iiB++) {
            err = pA_sort[iiA] - pB_sort[iiB];
            
            if(err < -tol) {
                // A is significantly less than B. Because both vectors
                // are sorted and we are increasing B there is no need to keep
                // searching, this value will not be found
                last_break = iiB;
                break;
            }
            else if(err > tol) {
                // A is significantly larger than B, this is ok because the
                // vectors are sorted and we are iterating up B until the
                // two values are close
            }
            else {
                // match found
                
                // if one_sided check that the sign of the err matches the
                // sign of the tolerance value
                if(!one_sided || (one_sided && err*tol_sign > 0)) {
                    match      = true;
                    break;
                }
            }
        }
        
        if( match ) {
            pIdx[(int)pA_idx[iiA]]  = pB_idx[iiB]+1;
            pMask[(int)pA_idx[iiA]] = true;
            last_break = iiB; 
        }
        else {
            pIdx[(int)pA_idx[iiA]]  = 0;
            pMask[(int)pA_idx[iiA]] = false; 
        }
    }
    
    pMask = (bool*)mxRealloc(pMask, nA*sizeof(bool));
    assignToMxArray(pMask, 1, nA, plhs[0]);
    if(nlhs > 1 ) {
        pIdx = (double*)mxRealloc(pIdx, nA*sizeof(double));
        assignToMxArray(pIdx, 1, nA, plhs[1]);
    }
    else {
        mxFree(pIdx);
    }
    mxFree(pA_sort);
    mxFree(pA_idx);
    mxFree(pB_sort);
    mxFree(pB_idx);
}


void print_usage() {
    mexPrintf("mex_setdiff_tol(A,B,tolerance)\n");
}