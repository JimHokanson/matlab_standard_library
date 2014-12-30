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
 *  mex minMaxOfDataSubset.cpp COMPFLAGS="$COMPFLAGS /arch:AVX /fp:fast"
 *
 *  2) 
 *  mex -v minMaxOfDataSubset.cpp
 *
 *  
 *
 *
 */

#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    
    /*
     *
     *  [min_chans,max_values,max_I,min_I] =
     *  	minMaxOfDataSubset(data,start1,stop1,start2,stop2,dim_1_or_2)
     *
     *
     *  Inputs:
     *  ----------
     *  dim_1_or_2:
     *      Dimension over which to compute the minimum and maximum.
     *
     *  Outputs:
     *  --------
     *
     */

    //TODO: Support dimension 2
    //TODO: Build in switching for inf/nan,etc checks ...
    //TODO: Check # of inputs and type
    
    

    double *data    = (double *)mxGetData(prhs[0]);
    double *starts1 = (double *)mxGetData(prhs[1]);
    double *ends1   = (double *)mxGetData(prhs[2]);
    double *starts2 = (double *)mxGetData(prhs[3]);
    double *ends2   = (double *)mxGetData(prhs[4]);
    double dim_use  = mxGetScalar(prhs[5]);
    
    
    mwSize n_chans;
    mwSize n_groups;
    
    mwSize assignment_offset = -1;
    mwSize row_start, row_end, col_start, col_end;
    mwSize n_values;
    
    double *init_offset;
    double *data_offset;
        
    if (dim_use == 1){
        n_chans  = (mwSize)(*ends2 - *starts2 + 1);
        n_groups = mxGetNumberOfElements(prhs[1]);
        plhs[0]  = mxCreateNumericMatrix(n_groups,n_chans,mxDOUBLE_CLASS,mxREAL);
        plhs[1]  = mxCreateNumericMatrix(n_groups,n_chans,mxDOUBLE_CLASS,mxREAL);
        plhs[2]  = mxCreateNumericMatrix(n_groups,n_chans,mxDOUBLE_CLASS,mxREAL);
        plhs[3]  = mxCreateNumericMatrix(n_groups,n_chans,mxDOUBLE_CLASS,mxREAL);
    } else {
        n_chans  = (mwSize)(*ends1 - *starts1 + 1);
        n_groups = mxGetNumberOfElements(prhs[3]);
        plhs[0]  = mxCreateNumericMatrix(n_chans,n_groups,mxDOUBLE_CLASS,mxREAL);
        plhs[1]  = mxCreateNumericMatrix(n_chans,n_groups,mxDOUBLE_CLASS,mxREAL);
        plhs[2]  = mxCreateNumericMatrix(n_chans,n_groups,mxDOUBLE_CLASS,mxREAL);
        plhs[3]  = mxCreateNumericMatrix(n_chans,n_groups,mxDOUBLE_CLASS,mxREAL);
    }
    
    
    double *xp, *xend, *minp, *maxp;
    double *all_max, *all_min, *all_max_I, *all_min_I;
    
    double  *xr;
    
    mxArray *lhs[2], *x;
    
    all_max   = (double *) mxGetData(plhs[0]);
    all_min   = (double *) mxGetData(plhs[1]);
    all_max_I = (double *) mxGetData(plhs[2]);
    all_min_I = (double *) mxGetData(plhs[3]);
    
    mwSize n_rows = mxGetM(prhs[0]);
    mwSize n_cols = mxGetN(prhs[0]);

        data_offset = data; // + (row_start*n_rows);
        
        x =  mxCreateDoubleMatrix(1, 1, mxREAL);
        
        xr = mxGetPr(x);
        //mxFree(mxGetPr(x))
        
        lhs[0] = mxCreateDoubleScalar(0);
        lhs[1] = mxCreateDoubleScalar(1);
        
        for (mwSize iChan = 0; iChan < n_chans; iChan++){

            //We are looping over the subset of data which we are working with
            for (mwSize iGroup = 0; iGroup < n_groups; iGroup++){
                row_start = (mwSize) starts1[iGroup];
                
                xp = data_offset + row_start - 1;
                //n_values = row_end - row_start + 1;
                                
                mxSetPr(x,xp);
                mxSetM(x,1);
                mxSetN(x,1);
                
                assignment_offset++;
                mexCallMATLAB(2, lhs, 1, &x, "min");
                all_min[assignment_offset] = *mxGetPr(lhs[0]);
                all_min_I[assignment_offset] = *mxGetPr(lhs[1]);
                
                mexCallMATLAB(2, lhs, 1, &x, "max");
                all_max[assignment_offset] = *mxGetPr(lhs[0]);
                all_max_I[assignment_offset] = *mxGetPr(lhs[1]); 

            }
            data_offset += n_rows;
        }
        
          /* Free allocated matrices */
//     mxSetPr(x,xr);
//     mxDestroyArray(x);
//     mxDestroyArray(lhs[0]);
//     mxDestroyArray(lhs[1]);
    //plhs[0] = lhs[0];  
    
}



// // // // // //  int mexCallMATLAB(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[], const char *functionName);
// // // // // //                 
// // // // // //                 
// // // // // //                 
// // // // // //                 minp = xp;
// // // // // //                 maxp = xp;
// // // // // //                 
// // // // // //                 while (xp < xend) {
// // // // // //                     if (*xp > *maxp){
// // // // // //                         maxp = xp;
// // // // // //                     } else if (*xp < *minp) {
// // // // // //                         minp = xp;
// // // // // //                     }
// // // // // //                     xp++;
// // // // // //                 }
// // // // // //                 
// // // // //                 
// // // // //                 //all_max[assignment_offset]   = *maxp;
// // // // //                 //all_min[assignment_offset]   = *minp;
// // // // //                 //all_max_I[assignment_offset] = minp - data_offset + 1;
// // // // //                 //all_min_I[assignment_offset] = maxp - data_offset + 1;
