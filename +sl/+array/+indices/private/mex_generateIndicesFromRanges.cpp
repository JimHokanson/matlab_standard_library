#include "MexSupport.h"
#include "mat.h"
#include "mex.h"
#include "matrix.h"

using namespace MexSupport;
void print_usage();
void mexFunction(int nlhs, mxArray** plhs, int nrhs, const mxArray* prhs[])
{
    if(nlhs < 1 || nrhs != 2)
    {
        print_usage();
        return;
    }
    // check type
    const MexDouble *I1 = mxGetPr(prhs[0]);
    const MexDouble *I2 = mxGetPr(prhs[1]);
    
    int nI1 = mxGetNumberOfElements(prhs[0]);
    int nI2 = mxGetNumberOfElements(prhs[1]);
    
    if (nI1 != nI2)    
    {
        mexErrMsgTxt("size(I1) ~= size(I2)");
    }
    
    
    // determine the size of the output vector by summing the length of all 
    // input intervals
    int totalSamps = 0;
    for(int iiSegment = 0; iiSegment < nI1; iiSegment++)
        totalSamps += I2[iiSegment] - I1[iiSegment] + 1;
      
    int curEnd   = -1;
    int curStart = 0;

    MexDouble * output = (MexDouble*)mxMalloc(sizeof(MexDouble)*totalSamps);
    for(int iiSegment = 0; iiSegment < nI1; iiSegment++)
    {
        curStart   = curEnd + 1;
        int nSamps = I2[iiSegment] - I1[iiSegment] + 1;
        curEnd     = curStart + nSamps - 1;
        
        for (int iiElement = 0; iiElement < nSamps; iiElement++ )
        {
            output[curStart+iiElement] = I1[iiSegment]+iiElement;
        }
    }

    assignToMxArray(output, 1, totalSamps, plhs[0]);
    return;
}

void print_usage(void)
{
    mexPrintf("sup?\n");
}