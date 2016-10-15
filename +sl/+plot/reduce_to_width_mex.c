#include "mex.h"
//
//  setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
//
//  mex -O LDFLAGS="$LDFLAGS -fopenmp"  CFLAGS="$CFLAGS -std=c11 -fopenmp -mavx"  reduce_to_width_mex.c  
//

/*
n_channels = 2;
data = [1 2 3 4 7    1 8 1 8 9   2 9 8 3 9    2 4 5 6 2    9 3 4 8 9    3 9 4 2 3   4 9 0 2 9]';
%data = repmat(data,[1 n_channels]);
data = repmat(data,[5000000 n_channels]);
data(23,1:n_channels) = -1:-1:-1*n_channels;
len_data_p1 = size(data,1)+1;
 tic
 for i = 1:10
[min_data,max_data] = sl.plot.reduce_to_width_mex([],data);
 end
 toc/10
 
 tic
 for i = 1:10
 min_data2 = min(reshape(data,[5 35000000 n_channels]),[],1);
 max_data = max(reshape(data,[5 35000000 n_channels]),[],1);
 end
 toc/10
 
 isequal(min_data,squeeze(min_data2))
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
    
    
    double *input_data = mxGetData(prhs[1]);
    mwSize n_samples = mxGetM(prhs[1]);
    mwSize n_chans = mxGetN(prhs[1]);
    
    //TODO: Get this from the user ...
    mwSize samples_per_chunk = 5;
    
    //TODO: Also need start and end ...
    
    //Integer division, should floor as desired
    mwSize n_chunks = n_samples/samples_per_chunk;
    
    double *min_data = mxMalloc(8*n_chans*n_chunks);
    double *max_data = mxMalloc(8*n_chans*n_chunks);
    
    #pragma omp parallel for simd
    for (mwSize iChan = 0; iChan < n_chans; iChan++){
        double *current_data_point = input_data + n_samples*iChan;
        double *local_min_data = min_data + n_chunks*iChan - 1;
        double *local_max_data = max_data + n_chunks*iChan - 1;
        double min;
        double max;
        for (mwSize iChunk = 0; iChunk < n_chunks; iChunk++){
            min = *current_data_point;
            max = *current_data_point;
            
            for (mwSize iSample = 1; iSample < samples_per_chunk; iSample++){
                if (*(++current_data_point) > max){
                    max = *current_data_point;
                }else if (*current_data_point < min){
                    min = *current_data_point;
                }
            }
            ++current_data_point;
            *(++local_min_data) = min;
            *(++local_max_data) = max;
        }
        
        //TODO: We might have one trailing bit of data to handle that didn't
        //fit evenly into the search ...
    }
    
    
    
    
    
    
    plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
    
    mxSetData(plhs[0],min_data);
    mxSetData(plhs[1],max_data);
    mxSetM(plhs[0],n_chunks);
    mxSetN(plhs[0],n_chans);
    mxSetM(plhs[1],n_chunks);
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