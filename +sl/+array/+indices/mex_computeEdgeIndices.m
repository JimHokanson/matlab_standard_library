%mex_computeEdgeIndices Mex implementation of computeEdgeIndices
%
%   [I1,I2] = computeEdgeIndices(TS,T1,T2) computes the edge indices 
%   for every T1 & T2 pair where T1 <= TS < T2.  I1 is the first value
%   where this is true, and I2 is the last, and is equivalent to
%   the code below, assuming that T1(n) < T2(n), but should be alot faster.
%
%   Note: For missing pairs (no events between them), these get 
%   returned as 1,0 for I1 & I2 respectively.  Searching for I2 = 0 will
%   indicate which pairs have no events in between.  In addition the # of
%   events can be calculated as I2 - I1 + 1, which results in 0, for I2 = 0
%   and I1 = 0.
%
%   I1      : For every T1,T2 pair, the FIRST index at which TS falls 
%             between the two times values
%   I2      : For every T1,T2 pair, the LAST index, "               "
%
%   TS      : Time of events
%   T1      : Left time edges for computing indices 
%   T2      : Right time edges for computing indices
%   
%   COMPUTING EFFICIENCY (IMPORTANT REQUIREMENT):
%   The computing efficiency comes in from the assumption that both T1 and
%   T2 are ordered within themselves, T1(n) < T1(n+1) & the same for T2,
%   this means when searching for TS events that are between T1(n) and
%   T2(n), we only need to start the search (on the left side) whereever
%   T1(n-1) left off.  I.E. If TS = [1 3 5] and I1(n-1) is index 2, we know
%   that I1(n), if valid (i.e. not empty and hence = 1), has to be at least
%   2 because T1(n - 1) is greater than 1 (the first index of Ts), and 
%   hence T1(n) will also be.  This means that instead of every T1,T2 pair
%   searching over all Ts, it can do search in sliding windows, starting
%   the search wherever the last index left off.
%
%   Examples
%   --------
%   TS = [1 3 5 10];
%   T1 = [0 2 8];
%   T2 = [2 9 10];
%
%   [I1,I2] = sl.array.indices.mex_computeEdgeIndices(TS,T1,T2);
%   
%   I1 => [1 2 4];
%   I2 => [1 3 4];
%
%   Note, this says, for T1(1) = 0 & T2(1) = 2
%   I1(1) = 1
%   I2(1) = 1
%   indicating that  TS(1:1) is between 0 and 2
%
%   For T1(2) = 2 & T2(2) = 9
%   I1(2) = 2
%   I2(2) = 3
%   indicating that TS(2:3) is between 2 and 9
%   
% tags: mex, array operation, masking 
% See also: computeEdgeIndices