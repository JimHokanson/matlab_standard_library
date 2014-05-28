function idxs = computeNearestIndices(ts,ref_time_array)
% computeNearestIndices  find the indices of TS nearest to the values in T1
% 
%   Inputs:
%   -------
%   ts :
%       Series of time points
%   ref_time_array : array
%       Array from which to find the closest indices.
%
%   See also: 
%   mex_computeNearestIndices 
%   computeEdgeIndices


    idxs = interp1(ts,1:length(ts),ref_time_array,'nearest','extrap');
