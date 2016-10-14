#include "mex.h"
//
//  setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
//
//  mex -O LDFLAGS="$LDFLAGS -fopenmp"  CFLAGS="$CFLAGS -std=c11 -fopenmp -mavx"  reduce_to_width_mex.c  
//

/*
data = [1 2 3 4 7    1 8 1 8 9   2 9 8 3 9    2 4 5 6 2    9 3 4 8 9    3 9 4 2 3   4 9 0 2 9]';
%data = repmat(data,[1 4]);
data = repmat(data,[5000000 4]);
data(23,1:4) = [-1 -2 -3 -4];
len_data_p1 = size(data,1)+1;
bounds = [1:5:len_data_p1];
 tic
 for i = 1:10
[min_data,max_data] = sl.plot.reduce_to_width_mex(bounds,data);
 end
 toc/10
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    //
    //  min_max_data = reduce_to_width_mex(bound_indices,data);
    //
    //  Inputs
    //  ------
    //  [min_data,max_data] = reduce_to_width_mex(bounds,data);
    
    //Let's assume we are given the indices
    //Later on we can add that code here as well ...
    
    double min;
    double max;
    //double *current_data_point;
    double *bound_indices;
    double *data;
    double *min_data;
    double *max_data;
    double *p_min_data;
    double *p_max_data;
    mwSize n_samples, n_chans;
    mwSize n_bounds;
    mwSize start_sample;
    mwSize stop_sample;
    
    bound_indices = mxGetData(prhs[0]);
    n_bounds = mxGetNumberOfElements(prhs[0]);
    
    data = mxGetData(prhs[1]);
    n_samples = mxGetM(prhs[1]);
    n_chans = mxGetN(prhs[1]);
    
    min_data = mxMalloc(8*n_chans*(n_bounds-1));
    max_data = mxMalloc(8*n_chans*(n_bounds-1));
    
//     mwSize data_chan_offset = 0;
//     mwSize bounds_chan_offset = 0;
//     p_min_data = min_data;
//     p_max_data = max_data;
//     //#pragma omp parallel for
//     for (mwSize iChan = 0; iChan < n_chans; iChan++){
//         //#pragma omp parallel for
//         //- 1 for 0-based and -1 for going 1 before that
//         stop_sample = ((mwSize) bound_indices[0]-1) + data_chan_offset - 1;
//         for (mwSize iBound = 0; iBound < (n_bounds-1); iBound++){
//             //TODO: Need an offset in here for the channel ...
//             start_sample = stop_sample + 1;
//             //start_sample = ((mwSize) bound_indices[iBound]-1) + data_chan_offset;
//             stop_sample = ((mwSize) bound_indices[iBound+1]-1) + data_chan_offset;
//             //mexPrintf("Start and stop: %d  %d\n",start_sample,stop_sample);
//             current_data_point = &data[start_sample];
//             min = max = *current_data_point;
//             for (mwSize j = start_sample + 1; j < stop_sample; j++){
//                 if (*(++current_data_point) > max){
//                     max = *current_data_point;
//                 }else if (*current_data_point < min){
//                     min = *current_data_point;
//                 }
//             }
//             *(++p_min_data) = min;
//             *(++p_max_data) = max;
//         }
//         
//         data_chan_offset = n_samples*(iChan + 1);
// //         bounds_chan_offset = (n_bounds-1)*(iChan);
//         //mexPrintf("chan offset: %d\n",chan_offset);
//     }
    
    #pragma omp parallel for
    for (mwSize iChan = 0; iChan < n_chans; iChan++){
        mwSize data_chan_offset = n_samples*iChan;
        double *current_data_point;
        current_data_point = data + data_chan_offset;
        min = max = *current_data_point;
        for (mwSize iSample = 1; iSample < n_samples; iSample++){
                if (*(++current_data_point) > max){
                    max = *current_data_point;
                }else if (*current_data_point < min){
                    min = *current_data_point;
                }
        }
        min_data[iChan] = min;
        max_data[iChan] = max;
    }
    
    
    
    
    
    
    plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
    
    mxSetData(plhs[0],min_data);
    mxSetData(plhs[1],max_data);
    mxSetM(plhs[0],n_bounds-1);
    mxSetN(plhs[0],n_chans);
    mxSetM(plhs[1],n_bounds-1);
    mxSetN(plhs[1],n_chans);
    
    
    //1
    
    //Matlab code ...
// lefts  = bound_indices(1:end-1);
// rights = [bound_indices(2:end-1)-1 bound_indices(end)];
// 
// for iRegion = 1:length(lefts)
//     yt = y(lefts(iRegion):rights(iRegion), iChan);
//     [~, indices(1,iRegion)] = min(yt);
//     [~, indices(2,iRegion)] = max(yt);
// end
// 
// indices = bsxfun(@plus,indices,lefts-1);
// indices = h__orderIndices(indices);
    
    
}