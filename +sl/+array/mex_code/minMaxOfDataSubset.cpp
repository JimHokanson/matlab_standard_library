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
 * 
 *  1)
 *  mex -v minMaxOfDataSubset.cpp COMPFLAGS="$COMPFLAGS /arch:AVX /fp:fast"
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
    mwSize start1, end1, start2, end2;
    
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
    
    all_max   = (double *) mxGetData(plhs[0]);
    all_min   = (double *) mxGetData(plhs[1]);
    all_max_I = (double *) mxGetData(plhs[2]);
    all_min_I = (double *) mxGetData(plhs[3]);
    
    mwSize n_rows = mxGetM(prhs[0]);
    mwSize n_cols = mxGetN(prhs[0]);
    
    if (dim_use == 1){
        data_offset       = data;
        
        for (mwSize iChan = 0; iChan < n_chans; iChan++){
            
            //We are looping over the subset of data which we are working with
            for (mwSize iGroup = 0; iGroup < n_groups; iGroup++){
                start1  = starts1[iGroup];
                end1    = ends1[iGroup];
                
                xp   = data_access_pointer_offset + start1;
                xend = data_access_pointer_offset + end1;
                
                minp = xp;
                maxp = xp;
                
                while (xp < xend) {
                    if (*xp > *maxp){
                        maxp = xp;
                    } else if (*xp < *minp) {
                        minp = xp;
                    }
                    xp++;
                }
                
                assignment_offset++;
                all_max[assignment_offset]   = *maxp;
                all_min[assignment_offset]   = *minp;
                all_max_I[assignment_offset] = minp - data_index_offset;
                all_min_I[assignment_offset] = maxp - data_index_offset;
                
            }
            start2++;
            data_access_pointer_offset += n_rows;
        }
    } else { 

         

//grabbing chunks over 2nd dimension ...
        
//         for (mwSize iGroup = 0; iGroup < n_groups; iGroup++){
//             start1  = (mwSize) bounds1[iGroup][0];
//             end1    = (mwSize) bounds1[1][1];
//             start2  = (mwSize) bounds2[0];
//             end2    = (mwSize) bounds2[1];
//             
//             xp   = data + (start1 - 1);
//             xend = data + (end1 - 1);
//             
//             minp = xp;
//             maxp = xp;
//             
//             while (xp < xend) {
//                 if (*xp > *maxp){
//                     maxp = xp;
//                 } else if (*xp < *minp) {
//                     minp = xp;
//                 }
//                 xp++; //Wrong for 2d
//             }
//             
//             all_max[0]   = *maxp;
//             all_min[0]   = *minp;
//             all_max_I[0] = (minp - data + 1); //Wrong for 2d
//             all_min_I[0] = (maxp - data + 1); //Wrong for 2d
//         }
        
    }
    
}