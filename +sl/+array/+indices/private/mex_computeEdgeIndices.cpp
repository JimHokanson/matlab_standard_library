#include <string>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include "mex.h"
#include "matrix.h"

#include "MexSupport.h"
#include "computeEdgeIndices.h"

using namespace std;
using namespace MexSupport;
void print_usage();
void mexFunction( int nlhs, mxArray **plhs, int nrhs, const mxArray *prhs[]) 
{
    if(nlhs != 2 || nrhs != 3)
    {
        print_usage();
        return;
    }

    if (!mxIsNumeric(prhs[0])
            || !mxIsNumeric(prhs[1])
            || !mxIsNumeric(prhs[2]))
    {
        print_usage();
        return;
    }

    MexDouble* ts = mxGetPr(prhs[0]);
    MexDouble* t1 = mxGetPr(prhs[1]);
    MexDouble* t2 = mxGetPr(prhs[2]);

    int nTSrows = mxGetM(prhs[0]);
    int nTScols = mxGetN(prhs[0]);

    int nT1rows = mxGetM(prhs[1]);
    int nT1cols = mxGetN(prhs[1]);

    int nT2rows = mxGetM(prhs[2]);
    int nT2cols = mxGetN(prhs[2]);

    if (nT1rows != nT2rows)
    {
        mexErrMsgTxt("T1 & T2 must have the same dimensions");
        return;
    }

    if (nT1rows != nT2rows)
    {
        mexErrMsgTxt("T1 & T2 must have the same dimensions");
        return;
    }

    // more error cehcks

    int nTs = mxGetNumberOfElements(prhs[0]);
    int nT1 = mxGetNumberOfElements(prhs[1]);
    
    MexDouble* I1(0x0);
    MexDouble* I2(0x0);
    computeEdgeIndices(nTs, nT1,ts,t1,t2,I1,I2);

    // increment indices by 1 to convert to base-1 convention
    for(int ii = 0; ii < nT1;ii++)
    {
        I1[ii]++;
        I2[ii]++;
    }
            
    assignToMxArray(I1,nT1rows,nT1cols,plhs[0]);
    assignToMxArray(I2,nT1rows,nT1cols,plhs[1]);

}

void print_usage()
{
    mexPrintf("usage: [i1,i2] = computeEdgeIndices(ts,t1,t2,check)");
}
