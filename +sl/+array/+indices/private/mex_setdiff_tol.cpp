
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
    bool onesided = false;
    int tol_sign  = 1;
    if( nrhs > 3 ) {
        onesided	 = *mxGetLogicals(prhs[3]);
        tol_sign = (tol > 0 ? 1 : -1);
        tol			 = fabs(tol);
    }
    
    int nA = mxGetNumberOfElements(prhs[0]);
    int nB = mxGetNumberOfElements(prhs[1]);
    
    double *pA_sort(0x0);
    double *pA_idx(0x0);
    sort_with_index(pA, nA, pA_sort, pA_idx);
    
    double *pB_sort(0x0);
    double *pB_idx(0x0);
    sort_with_index(pB, nB, pB_sort, pB_idx);
    
    double* pC   = (double*)mxMalloc(sizeof(double)*nA);
    double* piiA = (double*)mxMalloc(sizeof(double)*nA);
    
    int nC     = nA;
    int iiC    = 0;
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
                break;
            }
            else if(err > tol) {
                // A is significantly larger than B, this is ok because the
                // vectors are sorted and we are iterating up B until the
                // two values are close
            }
            else {
                // match found
                
                // if onesided check that the sign of the err matches the
                // sign of the tolerance value
                if(!onesided || (onesided && err*tol_sign > 0)) {
                    match      = true;
                    last_break = iiB;
                    break;
                }
            }
        }
        
        if( !match ) {
            // This statement prevents repeat matches from being included
            // in the output, e.g. A = [1 1 2 2 2] and B = [2] then C = 1.
            //
            // This is implemented by starting the search on the last element
            // of B that broke the above iteration
            //
            // This follows the convention of setdiff
            if( iiA == 0 \
                    || iiB != last_break \
                    || (iiB == last_break && err < -tol && (pA_sort[iiA] - pA_sort[iiA-1] > tol))) {
                piiA[iiC]  = pA_idx[iiA]+1;
                pC[iiC]    = pA_sort[iiA];
                last_break = iiB;
                iiC++;
            }
            else {
                piiA[iiC-1]  =  pA_idx[iiA]+1;
            }
        }
    }
    
    pC = (double*)mxRealloc(pC, iiC*sizeof(double));
    assignToMxArray(pC, 1, iiC, plhs[0]);
    if(nlhs > 1 ) {
        piiA = (double*)mxRealloc(piiA, iiC*sizeof(double));
        assignToMxArray(piiA, 1, iiC, plhs[1]);
    }
    else {
        mxFree(piiA);
    }
    mxFree(pA_sort);
    mxFree(pA_idx);
    mxFree(pB_sort);
    mxFree(pB_idx);
}


void print_usage() {
    mexPrintf("mex_setdiff_tol(A,B,tolerance)\n");
}