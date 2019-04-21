#include "mex.h"
#include <math.h> 
#include "float.h"
#include <immintrin.h>

//                      MB       Pal
//single 2 stage simd   7.2          
//single 2 stage openmp 6.2    
//sinlge 2 stage plain  3.8     
//single 1 pass plain   11.2     
//--------------------------
//


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

//Defined variables:
//threshold ...
//TODO: We might want to 
#define GET_EVENT_COUNT(f1,index1,f2,index2) \
    /* For example GET_EVENT_COUNT(>=,i+1,<,i)  rising edge event  */ \
    mwSize count = 0; \
    /*PRAGMA("omp parallel for reduction(+ : count)") */\
    for (mwIndex i = 0; i < n_data_samples-1; i++){ \
       /*Note, order here matters for speed*/ \
       if (data[index1] f1 threshold && data[index2] f2 threshold){ \
          count = count + 1; \
       } \
    }
    
//     int r4;
//     clock_begin = clock();
//     for (int i = 0; i <1e7; i+=8){
//         m1 = _mm256_loadu_ps(data+i);
//         m2 = _mm256_loadu_ps(data+i+1);
//         
//         r1 = _mm256_cmp_ps(m1, m0, 17);
//         r2 = _mm256_cmp_ps(m2, m0, 29);
//         r3 = _mm256_and_ps(r1,r2);
//         r4 = _mm256_movemask_ps(r3);
//         count += _mm_popcnt_u32(r4);
//     }    
    
//TODO: We might want to 
#define GET_EVENT_COUNT2(f1,index1,f2,index2,step_size,load_fcn,cmp_fcn,and_fcn,mask_fcn,o1,o2,reg_type,set1_fcn) \
    reg_type m0 = set1_fcn(threshold);\
    reg_type m1; \
    reg_type m2; \
    reg_type r1; \
    reg_type r2; \
    reg_type r3; \
    int r4; \
    /* For example GET_EVENT_COUNT(>=,i+1,<,i)  rising edge event  */ \
    mwSize count = 0; \
    /*PRAGMA("omp parallel for reduction(+ : count)")*/ \
    for (mwIndex i = 0; i <n_data_samples-1-step_size; i+=step_size){ \
        m1 = load_fcn(data+i); \
        m2 = load_fcn(data+i+1); \
        r1 = cmp_fcn(m1, m0, 17); \
        r2 = cmp_fcn(m2, m0, 29); \
        r3 = and_fcn(r1,r2); \
        r4 = mask_fcn(r3); \
        count += _mm_popcnt_u32(r4); \
    } \
    for (mwIndex i = n_data_samples-1-step_size; i < n_data_samples-1; i++){ \
       /*Note, order here matters for speed*/ \
       if (data[index1] f1 threshold && data[index2] f2 threshold){ \
          count = count + 1; \
       } \
    }

    
//This is the 2nd time through the loop, here we hold onto the indices
//Note that because we know the count, we do 1 allocation then never
//check for overloads ...
    
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
    //RUN_STD_CODE(>=,i+1,<,i,1); 
    
    //This is way slower for some reason with openmp
    //faster than just openmp (when openmp is disabled)
    //I wonder if we would get better performance if we split parts of the loop
    //up like we do for 
    //GET_EVENT_COUNT2(>=,i+1,<,i,8,_mm256_loadu_ps,_mm256_cmp_ps,
    //        _mm256_and_ps,_mm256_movemask_ps,17,19,__m256,_mm256_set1_ps);
    //POPULATE_EVENTS(>=,i+1,<,i,1);
    
    //One solution
    //-------------------------------------------------------------
    mwSize sz = 5000;    //TODO: make this based on data
    double *pout = mxCalloc(sz,sizeof(double));
    mwSize count = 0; 
    for (mwIndex i = 0; i < n_data_samples-1; i++){
       if (data[i+1] >= threshold && data[i] < threshold){
          if (count == sz){
              sz = sz*2;
              pout = mxRealloc(pout,sz*sizeof(double));
          }
          pout[count] = i + 1;
          count = count + 1;
       }
    }
    
  	mxSetData(indices,pout);
    mxSetN(indices,count);
    
    if (0){
    //Other solution - assume spareness, maybe toggle with above ...
    //Ideally we could specify which is sparse - exceeding threshold or not
    //  from the input
    //---------------------------------------------------------------------
    __m256 m0 = _mm256_set1_ps(threshold);
    __m256 m1;
    __m256 m2;
    __m256 r1;
    __m256 r2;
    __m256 r3;
    int r4;
    int n_matches = 0;
    mwSize sz = 5000;    //TODO: make this more reasonable
    double *pout = mxCalloc(sz,sizeof(double));
    mwSize count = 0; 
    for (mwIndex i = 0; i < n_data_samples-1-8; i+=8){
        m1 = _mm256_loadu_ps(data+i); 
        m2 = _mm256_loadu_ps(data+i+1); 
        
        r1 = _mm256_cmp_ps(m1, m0, 17);
        r2 = _mm256_cmp_ps(m2, m0, 29);
        r3 = _mm256_and_ps(r1,r2); 
        r4 = _mm256_movemask_ps(r1);
        if (r4){
            //12.88 before testing for 1  9.97 ms
            
            
            
            //Sub 1 - very slow due to bmi codes
//             n_matches = _mm_popcnt_u32(r4);
//             if (count+n_matches >= sz){
//                 sz = sz*2;
//                 pout = mxRealloc(pout,sz*sizeof(double));
//             }
            
            
            //This is really slow ...
//             for (int j = 0; j < n_matches; j++){
//                 pout[count] = i + 1 + _blsi_u32(r4);
//                 r4 = _blsr_u32(r4);
//                 count += 1;  
//             }
            
            
            //Sub 2 - 
            n_matches = _mm_popcnt_u32(r4);
            
            //Note, if we are already at the limit, we'll need more
            //since we know we have at least 1 ...
            if (count == sz){
                sz = sz*2;
                pout = mxRealloc(pout,sz*sizeof(double));
            }

                for (mwIndex j = i; j < i+8; j++){
                   if (data[j+1] >= threshold && data[j] < threshold){
                      pout[count] = j + 1;
                      count = count + 1;
                   }
                } 
            
            //Sub 3 - close to 2 ...
            
//                 for (mwIndex j = i; j < i+8; j++){
//                    if (data[j+1] >= threshold && data[j] < threshold){
//                        if (count == sz){
//                             sz = sz*2;
//                             pout = mxRealloc(pout,sz*sizeof(double));
//                         }
//                       pout[count] = j + 1;
//                       count = count + 1;
//                    }
//                 }  
            
            
            
        }
    }
    
    mxSetData(indices,pout);
    mxSetN(indices,count);
    
    
    }
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