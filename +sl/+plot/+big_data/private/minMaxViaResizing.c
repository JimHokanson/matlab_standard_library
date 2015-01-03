/*
 *  This code was started with the intention of getting the miniumum
 *  and maximum over a subset of an array. More specifically, the goal is
 *  to speed up plotting by calculating these values and only plotting them.
 *
 *  fp: http://msdn.microsoft.com/en-us/library/e7s85ffb.aspx
 *  arch: 
 *    64: http://msdn.microsoft.com/en-us/library/vstudio/jj620901(v=vs.110).aspx
 *    32: http://msdn.microsoft.com/en-us/library/vstudio/7t5yh4fd(v=vs.110).aspx
 *
 *
 *  On throwing in AVX:
 *      http://www.virtualdub.org/blog/pivot/entry.php?id=347
 *
 *  On min & max in Matlab:
 *      http://www.mathworks.com/matlabcentral/answers/41008-find-min-max-togather
 * 
 *  1)
 *  mex minMaxViaResizing.c COMPFLAGS="$COMPFLAGS /arch:AVX /fp:fast"
 *
 *  2) 
 *  mex -v minMaxViaResizing.c
 *
 *  
 *
 *
 */

#include <math.h>
#include "mex.h"

// A header for error messages:
#define ERR_HEAD "*** minMaxViaResizing[mex]: "
#define ERR_ID   "JHokanson:minMaxViaResizing:"
#define ERROR(id,msg) mexErrMsgIdAndTxt(ERR_ID id, ERR_HEAD msg);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    
    /*
     *
     *  [min_chans,max_values,max_I,min_I] =
     *  	minMaxViaResizing(data,new_m,new_n)
     *
     *  new_n : The output will be this size
     *  new_m : min and max will be computed across chunks of this size
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
    
    //This is done by Matlab on the function call
    //plhs[0]  = mxCreateNumericMatrix(1,new_n,mxDOUBLE_CLASS,mxREAL);
    //plhs[1]  = mxCreateNumericMatrix(1,new_n,mxDOUBLE_CLASS,mxREAL);
    //plhs[2]  = mxCreateNumericMatrix(1,new_n,mxDOUBLE_CLASS,mxREAL);
    //plhs[3]  = mxCreateNumericMatrix(1,new_n,mxDOUBLE_CLASS,mxREAL);
    
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