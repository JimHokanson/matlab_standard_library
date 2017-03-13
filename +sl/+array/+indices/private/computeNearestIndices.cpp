#include "computeNearestIndices.h"
#include "matrix.h"
#include "mex.h"
#include "MexDataTypes.h"

using namespace MexSupport;
void computeNearestIndices(int nTs, int nT1,
        const MexDouble* ts, 
        const MexDouble* t1, 
        MexDouble* &rI1)
{
    // THIS MEMORY MUST BE DEALLOCATED BY CALLER
    rI1 = (MexDouble*)mxMalloc(nT1*sizeof(MexDouble));
      
    int iiTimeStamp = 0;
    for(int iiEvent = 0; iiEvent < nT1; iiEvent++)
    {
        // find the first index of ts that is >= t1[iiEvent]
        while((iiTimeStamp < nTs) && (ts[iiTimeStamp] < t1[iiEvent]))
        {
            iiTimeStamp++;
        }
        
        rI1[iiEvent] = iiTimeStamp + 1; // +1 for conversion to 1-based index
        
        // Jump back to the previous timestamp if it was actually closer.
        // t1[iiEvent] will always be less than ts[iiTimestamp] but greater than ts[iiTimeStamp-1]
        if (iiTimeStamp > 0 && (iiTimeStamp == nTs || t1[iiEvent] - ts[iiTimeStamp-1] < ts[iiTimeStamp] - t1[iiEvent]) )
        {
            rI1[iiEvent] = iiTimeStamp; // -1+1 for conversion to 1-based index
        }
    }
    return;
}
