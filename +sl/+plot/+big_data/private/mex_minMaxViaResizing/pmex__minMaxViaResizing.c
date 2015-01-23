/*
 *
 *  Compile via:
 *  ------------
 *  mex -v pmex__minMaxViaResizing.c
 *
 *
 */

#define char16_t UINT16_T

#include <math.h>
#include "mex.h"

// A header for error messages:
#define ERR_HEAD "*** pmex__minMaxViaResizing[mex]: "
#define ERR_ID   "JHokanson:pmex__minMaxViaResizing:"
#define ERROR(id,msg) mexErrMsgIdAndTxt(ERR_ID id, ERR_HEAD msg);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    
    /*
     *
     *  [min_chans,min_I,max_values,max_I] = pmex__minMaxViaResizing(data,new_m,new_n)
     *
     *  Inputs:
     *  -------
     *  new_m : min and max will be computed across chunks of this size
     *  new_n : The output will be this size
     *
     *  Improvements:
     *  -------------
     *  1) I think the data input can be any type (not limited to double)
     *   - this should be tested and the check for double removed - or should
     *     we add a numeric check?
     *  2) Make sure there are no memory leaks from the function. I don't
     *     think so, but it would be helpeful to run a test for this ...
     *
     */
    
    mwSize new_m, new_n, old_m, old_n;
    mxArray *data;
    mxArray *lhs_c1[2];
    mxArray *lhs_c2[2];
    mxArray *in_min_max[3];
    mxArray *empty_input, *dim_input;
    
    // Check types of inputs:
    if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2])) {
        ERROR("BadInputType", "Inputs must be array of type DOUBLE.");
    }
    if (mxIsSparse(prhs[0]) || mxIsComplex(prhs[0])) {
        ERROR("BadDataType", "Data must be non-sparse and real.");
    }
    
    data  = prhs[0];
    new_m = (mwSize)mxGetScalar(prhs[1]);
    new_n = (mwSize)mxGetScalar(prhs[2]);
        
    old_m = mxGetM(data);
    old_n = mxGetN(data);
    mxSetM(data,new_m);
    mxSetN(data,new_n);
    
    in_min_max[0] = data;
    empty_input = mxCreateNumericMatrix(0,0,mxDOUBLE_CLASS,mxREAL);
    dim_input = mxCreateDoubleScalar(1);
    in_min_max[1] = empty_input; //Empty
    in_min_max[2] = dim_input; //1
    
    mexCallMATLAB(2, lhs_c1, 3, in_min_max, "min");
    plhs[0] = lhs_c1[0];
    plhs[1] = lhs_c1[1];
    
    mexCallMATLAB(2, lhs_c2, 3, in_min_max, "max");
    plhs[2] = lhs_c2[0];
    plhs[3] = lhs_c2[1];
    
    //Reset the size ...
    mxSetM(prhs[0],old_m);
    mxSetN(prhs[0],old_n);
    
    mxDestroyArray(empty_input);
    mxDestroyArray(dim_input);
    
}