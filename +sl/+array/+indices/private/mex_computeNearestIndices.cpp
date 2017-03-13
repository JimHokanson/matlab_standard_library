#include <string>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include "mex.h"
#include "matrix.h"

#include "MexSupport.h"
#include "computeNearestIndices.h"

using namespace std;
using namespace MexSupport;
void print_usage();
void mexFunction( int nlhs, mxArray **plhs, int nrhs, const mxArray *prhs[]) 
{
    if(nlhs != 1 || nrhs != 2)
    {
        print_usage();
        return;
    }

    if (!mxIsNumeric(prhs[0]) || !mxIsNumeric(prhs[1]))
    {
        print_usage();
        return;
    }

    MexDouble* ts = mxGetPr(prhs[0]);
    MexDouble* t1 = mxGetPr(prhs[1]);
    
    int nT1rows = mxGetM(prhs[1]);
    int nT1cols = mxGetN(prhs[1]);
    
    int nTs = mxGetNumberOfElements(prhs[0]);
    int nT1 = mxGetNumberOfElements(prhs[1]);
    
    MexDouble* I1(0x0);
    computeNearestIndices(nTs,nT1,ts,t1,I1);
            
    assignToMxArray(I1,nT1rows,nT1cols,plhs[0]);
}

void print_usage()
{
    mexPrintf("usage: i1 = computeEdgeIndices(ts,t1)");
}
