#include "mex.h"
#include "matrix.h"
#include <cmath>
#include "MexSupport.h"
#include "MexDataTypes.h"
#define ROUND(X) (fmod(X, 1.0) >= .5 ? ceil(X) : floor(X) );
using namespace MexSupport;
void print_usage();
void mexFunction(int nlhs, mxArray** plhs, int nrhs, const mxArray * prhs[]) {
    if(nlhs < 1) {
        print_usage();
        return;
    }
    
    plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    
    if(nrhs < 3) {
        print_usage();
        return;
    }
    
    // default to linear interpolation
    int method = 1;
    
    // check dimensionality of the inputs
    int nXDims  = mxGetNumberOfDimensions(prhs[0]);
    int nYDims  = mxGetNumberOfDimensions(prhs[1]);
    int nXiDims = mxGetNumberOfDimensions(prhs[2]);
    if (nXDims > 2 || nYDims > 2 ||  nXiDims > 2 ) {
        print_usage();
        return;
    }
    int MX     = mxGetM(prhs[0]);
    int NX     = mxGetN(prhs[0]);
    int numelX = MX*NX;
    if (MX > 1 && NX > 1) {
        mexErrMsgTxt("X must have one singleton dimension");
    }
    
    int MY     = mxGetM(prhs[1]);
    int NY     = mxGetN(prhs[1]);
    
    int MXi     = mxGetM(prhs[2]);
    int NXi     = mxGetN(prhs[2]);
    int numelXi = MXi*NXi;
    if (MXi > 1 && NXi > 1) {
        mexErrMsgTxt("Xi must have one singleton dimension");
    }
	
	if ( !mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2])) {
		mexErrMsgTxt("Input for vector lists must be double precision.");
	}
    
    // Forces vectors to be columns
    MexDouble* x  = mxGetPr(prhs[0]);
    MexDouble* Y  = mxGetPr(prhs[1]);
    MexDouble* xi = mxGetPr(prhs[2]);
    
    if( MY != MY) {
        //CAA TODO Need a good way of transposing.  The following code is close, but it
        // shits the bed
        //         if( MX == NY) {
        //             // too lazy to perform transpose in C
        //             mxArray *Ytranspose = mxCreateDoubleMatrix(0,0,mxREAL);
        //             mexCallMATLAB(1, &Ytranspose, 1, const_cast<mxArray**>(&prhs[1]), "transpose");
        //             Y  = mxGetPr(Ytranspose);
        //             MY = mxGetM(Ytranspose);
        //             NY = mxGetN(Ytranspose);
        //             mexPrintf("%d\n",mxGetNumberOfElements(Ytranspose));
        //             return;
        //         }
        //         else {
        mexErrMsgTxt("x and Y must have the same number of rows");
        //         }
    }
    
    if(nrhs == 4) {
        method = (int)(*mxGetPr(prhs[3]));
    }
    
    if( method != 1 && method != 0) {
        mexErrMsgTxt("method must be either 0 or 1");
    }
    // Gets the x spacing
    double ndx = 1.0/(x[1]-x[0]); // one over to perform divide only once
    
    
    MexDouble* Yi    = (MexDouble*)mxMalloc(sizeof(MexDouble)* numelXi*NY);
    if(Yi == 0x0)
    {       
        mexErrMsgTxt("Out Of Memory!\n");
    }
    double mex_nan    = mxGetNaN();
    if(method == 0) {
        // nearest neighbour interpolation
        int rxi(0);
        for(int ii = 0; ii < numelXi; ii++) {
            // indices of nearest-neighbors
            rxi = ROUND((xi[ii]-xi[0])*ndx);
            
            if( rxi < 0 || rxi >= numelX || xi[ii] == mex_nan ) {
                for(int jj = 0; jj < NY; jj++) {
                    Yi[jj*numelXi+ii] = mex_nan;
                }
            }
            else {
                // perform interpolation across columns
                for(int jj = 0; jj < NY; jj++) {
                    Yi[jj*numelXi+ii] = Y[jj*MY+rxi];
                }
            }
        }
    }
    else if(method == 1) {
        // linear interpolation
        int fxi(0);
        int idx = 0;
        int off = 0;
        for(int ii = 0; ii < numelXi-off; ii++) {
            // indices of nearest-lower-neighbors
            double dx = xi[ii]-x[0];
            fxi       = floor(dx*ndx)+1;
            if( fxi < off || fxi > numelX-1 || xi[ii] == mex_nan ) {
                for(int jj = 0; jj < NY; jj++) {
                    Yi[jj*numelXi+ii+off] = mex_nan;
                }
            }
            else {
                // perform interpolation across columns
                int col(0);
                for(int jj = 0; jj < NY; jj++) {
                    col = jj*MY;
                    Yi[jj*numelXi+ii+off] = (fxi-dx*ndx)*Y[col+fxi-1] +
                            (1-fxi+dx*ndx)*Y[col+fxi];
                    
                }
            }
            idx++;
        }
        // Assign a value to the final row
        int col(0);
        int end = numelXi-1;
        for(int jj = 0; jj < NY; jj++) {
            col = jj*numelXi;
            Yi[col+end] = Yi[col+end-1]+(Yi[col+end-1]-Yi[col+end-2]);
        }
    }
    assignToMxArray(Yi, numelXi, NY, plhs[0]);
}

void print_usage() {
    mexPrintf("Yi = mex_interp1(x,Y,xi,*method)\n");
}