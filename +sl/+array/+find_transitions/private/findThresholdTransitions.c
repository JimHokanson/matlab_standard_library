#include "mex.h"
#include <math.h> 
#include "float.h"

// Eventually I'd like this to get a lot fancier (more options, SIMD)
// but for now let's just do a no-limit find (as opposed to find with a
// max # of events

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    //
    //      Usage
    //      -----
    //      I = sl.array.findThresholdTransitions(data,threshold,type)
    //
    //      type : 0 >, off to on
    //             1 >, on to off (not implemented)
    //             etc. 
        
    if (nrhs != 3){
        mexErrMsgIdAndTxt("SL:findThresholdTransitions:call_error","Invalid # of inputs, 3 expected");
    }
    
    if (!mxIsClass(prhs[0],"double")){
        mexErrMsgIdAndTxt("SL:findThresholdTransitions:call_error","The input array must be of type double");
    }    
    
    if (!mxIsClass(prhs[1],"double")){
        mexErrMsgIdAndTxt("SL:findThresholdTransitions:call_error","The threshold must be of type double");
    }    
    
    if (!mxIsClass(prhs[2],"double")){
        mexErrMsgIdAndTxt("SL:findThresholdTransitions:call_error","The option type must be of type double");
    }    
    
    if (!(nlhs == 1)){
        mexErrMsgIdAndTxt("SL:findThresholdTransitions:call_error","Invalid # of outputs, 1 expected");
    }

    mwSize n_samples_data = mxGetNumberOfElements(prhs[0]);
    
    double *data = mxGetData(prhs[0]);
    double threshold = mxGetScalar(prhs[1]);
    int option = (int)mxGetScalar(prhs[2]);
    
    
    
    //1 Count the # of events
    //---------------------------------------------------------------------
    //Optimizations
    //----------------
    //Add sentinel (true at the end, only check end when in true
    //SIMD - cmpgt_sd
    //Allow the user to specify sparsity (high or low values)
    //      - Currently we are assuming sparse high (first check in loop)
    //Could try dynamic allocation
    
    int count = 0;
    //TODO: int might not be appropriate for large array data
    for (int i = 0; i < n_samples_data-1; i++){
       //Note, order here matters
       if (data[i+1] >= threshold && data[i] < threshold){
          count = count + 1;
          //With state machine, we skip the next check ...
       }
    }
    
    //2 Populate the output with the relevant indices
    //---------------------------------------------------------------------
    plhs[0] = mxCreateDoubleMatrix(1,count,mxREAL);
    
    double *pout = mxGetData(plhs[0]);
    
    int j = 0;
    while (count != 0){
       if (data[j] < threshold && data[j+1] >= threshold){
          count = count - 1;
          *pout = j + 1;
          pout++;
          j+=2;
       }else {
          j++; 
       }
    } 
    
}