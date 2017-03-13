#include "computeEdgeIndices.h"
#include "matrix.h"
#include "mex.h"
#include "MexDataTypes.h"

using namespace MexSupport;
void computeEdgeIndices(int nTs, int nT1,
        const MexDouble* ts, 
        const MexDouble* t1, 
        const MexDouble* t2, 
        MexDouble* &rI1,
        MexDouble* &rI2)
{
    // THIS MEMORY MUST BE DEALLOCATED BY CALLER
    rI1 = (MexDouble*)mxMalloc(nT1*sizeof(MexDouble));
    rI2 = (MexDouble*)mxMalloc(nT1*sizeof(MexDouble));
      
    int iiTimeStamp = 0;
    
    
    int kk = 0;
    for(int iiWindow = 0; iiWindow < nT1; iiWindow++)
    {
        rI1[iiWindow] = 0;
        rI2[iiWindow] = -1;
 
        // find the first index of ts that is >= t1[iiWindow]
        while(iiTimeStamp < nTs)
        {
            if(ts[iiTimeStamp] >= t1[iiWindow])
                break;
            else
                iiTimeStamp++;
        }
        
        // Only continue if
        //  - A value of TS was found after the start of this window
        if( iiTimeStamp < nTs)
        {
            rI1[iiWindow] = iiTimeStamp;
        
            // subtract one to ensure that first index can equal the last index 
            // when there is only one event in this window
            if( iiTimeStamp > 0)
                iiTimeStamp--;
            
            // kk is an intermediate value that starts iterating from the 
            // current stamp to the end of the window, or the end of ts, 
            // whichever comes first
            kk = iiTimeStamp;

            // find the last index of ts that is < t1[iiWindow]
            while(kk < nTs)
            {
                if (ts[kk] <= t2[iiWindow])
                    kk++;
                else
                    break;
            }
            
            // Only assign if:
            //  - we aren't past the end of TS
            // or
            //  - we are at the last index of TS
            //  - and the last element of TS is within the window
            if (kk < nTs || kk == nTs && (ts[kk-1] < t2[iiWindow]) )
                rI2[iiWindow] = kk-1;
        }
    }
    return;
}

void computeEdgeIndices_EqualWindows(int nTs, int nT1,
        const MexDouble* ts, 
        const MexDouble* windowCenter,
        double startOffset, 
        double endOffset, 
        MexDouble* &rI1,
        MexDouble* &rI2)
{
    // THIS MEMORY MUST BE DEALLOCATED BY CALLER
    rI1 = (MexDouble*)mxMalloc(nT1*sizeof(MexDouble));
    rI2 = (MexDouble*)mxMalloc(nT1*sizeof(MexDouble));
    
    int iiTimeStamp = 0;
    int kk = 0;
    
    double win_start(0.0);
    double win_end(0.0);
    for(int iiWindow = 0; iiWindow < nT1; iiWindow++)
    {
        rI1[iiWindow] = 0;
        rI2[iiWindow] = -1;
 
        // find the first index of ts that is >= t1[iiWindow]
        while(iiTimeStamp < nTs)
        {
            win_start = windowCenter[iiWindow]-startOffset;
            if(ts[iiTimeStamp] >= win_start)
                break;
            else
                iiTimeStamp++;
        }

        // Only continue if
        //  - A value of TS was found after the start of this window
        if( iiTimeStamp < nTs)
        {
            rI1[iiWindow] = iiTimeStamp;
            
            // subtract one to ensure that first index can equal the last index
            // when there is only one event in this window
            if( iiTimeStamp > 0)
                iiTimeStamp--;
            
            // kk is an intermediate value that starts iterating from the 
            // current stamp to the end of the window, or the end of ts, 
            // whichever comes first
            kk = iiTimeStamp;

            // find the last index of ts that is < t1[iiWindow]
            while(kk < nTs)
            {
                win_end = windowCenter[iiWindow]+endOffset;
                if (ts[kk] <= win_end)
                    kk++;
                else
                    break;
            }
            // Only assign if:
            //  - we aren't past the end of TS
            // or
            //  - we are at the last index of TS
            //  - and the last element of TS is within the window
            if (kk < nTs || kk == nTs && (ts[kk-1] < win_end) )
                rI2[iiWindow] = kk-1;
        }
    }
    return;
}

