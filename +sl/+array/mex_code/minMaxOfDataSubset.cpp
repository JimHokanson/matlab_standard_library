/*
 *  This code was started with the intention of getting the miniumum
 *  and maximum over a subset of an array. More specifically, the goal is
 *  to speed up plotting by calculating these values and only plotting them.
 
 
 
mex minMaxOfDataSubset.cpp
 
 */

#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) 
{
    
    // minMaxOfDataSubset(data,[start1 stop1],[start2 stop2],dim_1_or_2)
    
    //Corner cases: Not yet handled
    //-------------------------------
    //Empty array
    //NaN and Inf values
    
    //Output:
    //1) max values
    //2) indices
    //3) min values
    //4) indices
    
    //Other options ...
    //Handling NaN and Inf
    //TODO: Do error checking ...
    
        
    double *data    = (double *)mxGetData(prhs[0]);
    double *bounds1 = (double *)mxGetData(prhs[1]);
    double *bounds2 = (double *)mxGetData(prhs[2]);
    double dim_use  = mxGetScalar(prhs[3]);
    
    mwSize n_values;
    
    mwSize start1, end1, start2, end2;
    
    start1  = (mwSize) bounds1[0];
    end1    = (mwSize) bounds1[1];
    start2  = (mwSize) bounds2[0];
    end2    = (mwSize) bounds2[1];
    
	//mexPrintf("Start1: %d, end1: %d\n",start1,end1);
    
    if (dim_use == 1){
       n_values = end2 - start2 + 1;   
    } else {
       n_values = end1 - start1 + 1; 
    }
    
    //mexPrintf("N_values: %d\n",n_values);
    
    //TODO: Based on dimension, switch order to be n_values x 1
    //i.e. if dim == 1, 
    plhs[0] = mxCreateNumericMatrix(1,n_values,mxDOUBLE_CLASS,mxREAL);
    plhs[1] = mxCreateNumericMatrix(1,n_values,mxDOUBLE_CLASS,mxREAL);
    plhs[2] = mxCreateNumericMatrix(1,n_values,mxDOUBLE_CLASS,mxREAL);
    plhs[3] = mxCreateNumericMatrix(1,n_values,mxDOUBLE_CLASS,mxREAL);
    
    double *all_max, *all_min, *all_max_I, *all_min_I;
    
    all_max   = (double *) mxGetData(plhs[0]);
    all_min   = (double *) mxGetData(plhs[1]);
    all_max_I = (double *) mxGetData(plhs[2]);
    all_min_I = (double *) mxGetData(plhs[3]);
    
    //double dim_iterator;
    
    //TODO: Fix this based on dimensions ...
    //Grab first element 

    
    double *xp, *xend, *minp, *maxp;
    
    //TODO: Build in multi dimesion support
    
    //TODO: Build in switching for inf/nan,etc checks ...
    
    //cur_min = data[start1,start2];
    
    xp   = data + (start1 - 1);
    xend = data + (end1 - 1);
    
    minp = xp;
    maxp = xp;
    
    while (xp < xend) {
        if (*xp > *maxp){
           maxp = xp;  
        } else if (*xp < *minp) {
           minp = xp; 
        }
        xp++; //Wrong for 2d
    }
    
    all_max[0]   = *maxp;
    all_min[0]   = *minp;
    all_max_I[0] = (minp - data + 1); //Wrong for 2d
    all_min_I[0] = (maxp - data + 1); //Wrong for 2d

}