#ifndef COMPUTE_EDGE_INDICES_H
#define COMPUTE_EDGE_INDICES_H
/*
 * For a given set of sorted time stamps, ts, and a set of sorted window
 * start and stop times, t1 & t2, this method produces the first index into
 * ts that falls within a given window, I1, and the last index that falls
 * within it, I2.
 *
 * In the event that there are no time stamps within a given window
 * I1 = 0 and I2 = -1;
 *
 * CAVEATS
 * ========================================================================
 * - Memory for I1 and I2 must be deallocated by the calling function
 * - The units for ts, t1, and t2 must all be the same (e.g. seconds, milliseconds)
 *
 * INPUTS
 * ========================================================================
 * nTs - number of time stamps in ts vector
 * nT1 - number of time windows in t1 & t2 vectors
 * ts  - vector of time stamps
 * t1  - vector of time window start
 * t2  - vector of time window stop
 * rI1  - vector of returned start indices, must be null
 * rI2  - vector of returned stop indices, must be null
 */
void computeEdgeIndices(int nTs, int nT1,
        const double *ts,
        const double* t1,
        const double* t2,
        double* &rI1,
        double* &rI2);

/*
 * Identical to computeEdgeIndices, but instead of supplying a vector of t1 and
 * t2 times the user specifies a window center and start and end offsets from it.  
 * This removes the the requirement of generating t1 and t2 vectors
 *
 * CAVEATS
 * ========================================================================
 * - Memory for I1 and I2 must be deallocated by the calling function
 * - The units for ts, t1, and t2 must all be the same (e.g. seconds, milliseconds)
 *
 * INPUTS
 * ========================================================================
 * nTs  - number of time stamps in ts vector
 * nT1  - number of elements, windowCenters
 * ts   - vector of time stamps
 * windowCenter - the center of all windows
 * startOffset  - the offset from the windowCenter such that 
 *      t1 = windowCenter - startOffset 
 * endOffset    - the offset from the windowCenter such that 
 *      t2 = windowCenter + endOffset 
 * rI1 - vector of returned start indices
 * rI2 - vector of returned stop indices
 */
void computeEdgeIndices_EqualWindows(int nTs, int nT1,
        const double *ts,
        const double *windowCenter,
        double startOffset,
        double endOffset,
        double* &rI1,
        double* &rI2);
#endif /* COMPUTE_EDGE_INDICES_H */
