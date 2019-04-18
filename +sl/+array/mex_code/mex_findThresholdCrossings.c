#include "mex.h"
#include <math.h> 
#include "float.h"

#ifdef _MSC_VER
#define PRAGMA __pragma
#else
#define PRAGMA _Pragma
#endif

//  Compile:
//  mex mex_findThresholdCrossings.c
//
//  Accessed at:
//  I = sl.array.findThresholdCrossings(data,command,threshold,direction,varargin)
//
//  Improvements:
//  1) Expose openmp as a compile option
//  2) Allow tracking the minimum event spacing for jumps when populating
//      in other words, for stim events, these typically take place at close
//      to a fixed rate. If we save this rate 

//(data,command,threshold,direction)
#define INIT_INPUT_POINTERS(TYPE) \
  	TYPE *data = (TYPE *)mxGetData(prhs[0]); \
    TYPE *pthreshold = (TYPE *)mxGetData(prhs[2]); \
    TYPE threshold = *pthreshold;

//TODO: We might want to 
#define GET_EVENT_COUNT(f1,index1,f2,index2) \
    /* For example GET_EVENT_COUNT(>=,i+1,<,i)  rising edge event  */ \
    mwSize count = 0; \
    PRAGMA("omp parallel for reduction(+ : count)") \
    for (mwIndex i = 0; i < n_data_samples-1; i++){ \
       /*Note, order here matters for speed*/ \
       if (data[index1] f1 threshold && data[index2] f2 threshold){ \
          count = count + 1; \
       } \
    }
    
#define POPULATE_EVENTS(f1,index1,f2,index2,offset) \
    double *pout = mxCalloc(count,sizeof(double)); \
  	mxSetData(indices,pout); \
    mxSetN(indices,count); \
    mwIndex i = 0; \
    while (count != 0){ \
       if (data[index1] f1 threshold && data[index2] f2 threshold){ \
          count = count - 1; \
          *pout = i + offset; \
          pout++; \
          i+=2; \
       }else { \
          i++; \
       } \
    }

#define RUN_STD_CODE(f1,index1,f2,index2,offset) \
    GET_EVENT_COUNT(f1,index1,f2,index2); \
    POPULATE_EVENTS(f1,index1,f2,index2,offset); 
    
    
#define STD_INPUT_CALL indices, threshold, data, n_data_samples
#define STD_INPUT_DEFINE(type) mxArray *indices, type threshold, type *data, mwSize n_data_samples    


//TODO: Work out index of event (at start or end, vary based on rise or fall
    
void get_rising_gt_threshold_events_double(STD_INPUT_DEFINE(double)){
    RUN_STD_CODE(>=,i+1,<,i,1); 
}

void get_falling_gt_threshold_events_double(STD_INPUT_DEFINE(double)){
    RUN_STD_CODE(>=,i,<,i+1,1); 
}

void get_falling_lt_threshold_events_double(STD_INPUT_DEFINE(double)){
    RUN_STD_CODE(<=,i+1,>,i,1); 
}

void get_rising_lt_threshold_events_double(STD_INPUT_DEFINE(double)){
    RUN_STD_CODE(<=,i,>,i+1,1); 
}

void get_rising_gt_threshold_events_single(STD_INPUT_DEFINE(float)){
    RUN_STD_CODE(>=,i+1,<,i,1); 
}

void get_falling_gt_threshold_events_single(STD_INPUT_DEFINE(float)){
    RUN_STD_CODE(>=,i,<,i+1,1); 
}

void get_falling_lt_threshold_events_single(STD_INPUT_DEFINE(float)){
    RUN_STD_CODE(<=,i+1,>,i,1); 
}

void get_rising_lt_threshold_events_single(STD_INPUT_DEFINE(float)){
    RUN_STD_CODE(<=,i,>,i+1,1); 
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]){
    //
    //      Usage
    //      -----
    //      I = sl.array.findThresholdCrossings(data,command,threshold,direction)
    //
    //      type : 0 >, off to on
    //             1 >, on to off (not implemented)
    //             etc. 
        
    //Input Checks
    //---------------------------------------------------------------------
    if (nrhs != 4){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","Invalid # of inputs, 4 expected");
    }
    
    //data check
    if (!(mxIsClass(prhs[0],"double") || mxIsClass(prhs[0],"single"))){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The input array must be of type double or single");
    }    
    
    //command checks
    if (!mxIsClass(prhs[1],"double")){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The compare function must be of type double");
    }else if (mxGetNumberOfElements(prhs[1]) != 1){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The compare function must have length 1");
    }
    
    int command = (int) mxGetScalar(prhs[1]);
    if (!(command == '<' || command == '>')){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The compare function must be either > or <");
    }
    
    //threshold
    if (mxGetClassID(prhs[2]) != mxGetClassID(prhs[0])){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The threshold must be of the same type as the data");       
    }
  
    //direction
    if (!mxIsClass(prhs[3],"double")){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The direction must be of type double");
    }else if (mxGetNumberOfElements(prhs[3]) != 1){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The direction must have length 1");
    }
    
    int direction = (int) mxGetScalar(prhs[3]);
    if (!(direction == 'r' || direction == 'f')){
        mexErrMsgIdAndTxt("SL:findThresholdCrossings:call_error","The compare function must be either > or <");
    }
    
    //Output Checks
    //---------------------------------------------------------------------
    if (!(nlhs == 1)){
        mexErrMsgIdAndTxt("SL:findThresholdTransitions:call_error","Invalid # of outputs, 1 expected");
    }

    mwSize n_data_samples = mxGetNumberOfElements(prhs[0]);
    
    plhs[0] = mxCreateDoubleMatrix(1,0,mxREAL);
    mxArray *indices = plhs[0];
    
    if (mxIsClass(prhs[0],"double")){
        INIT_INPUT_POINTERS(double)
        //STD_INPUT_CALL indices, threshold, data, n_data_samples
        if (command == '>'){
            if (direction == 'r'){
                get_rising_gt_threshold_events_double(STD_INPUT_CALL);
            }else{
                get_falling_gt_threshold_events_double(STD_INPUT_CALL);
            }
        }else{
            if (direction == 'r'){
                get_rising_lt_threshold_events_double(STD_INPUT_CALL);
            }else{
                get_falling_lt_threshold_events_double(STD_INPUT_CALL);
            }
        }
    }else{
        INIT_INPUT_POINTERS(float)
        if (command == '>'){
            if (direction == 'r'){
                get_rising_gt_threshold_events_single(STD_INPUT_CALL);
            }else{
                get_falling_gt_threshold_events_single(STD_INPUT_CALL);
            }
        }else{
            if (direction == 'r'){
                get_rising_lt_threshold_events_single(STD_INPUT_CALL);
            }else{
                get_falling_lt_threshold_events_single(STD_INPUT_CALL);
            }
        }    
    }
    
}