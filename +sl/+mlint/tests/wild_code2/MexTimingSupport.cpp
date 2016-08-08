#include "MexTimingSupport.h"
#include "MexSupport.h"

static clock_t sSetTime;
namespace MexSupport{
    
    clock_t tic() {
        sSetTime = clock( );
        return sSetTime;
    }
    
    void toc() {
        clock_t now = clock( );
        mexPrintf("Elapsed time is %2.4f seconds.\n",(now-sSetTime)/(float)CLOCKS_PER_SEC);
    }
    
    void toc(clock_t &rSetTime) {
        clock_t now = clock( );
        mexPrintf("Elapsed time is %2.4f seconds.\n",(now-rSetTime)/(float)CLOCKS_PER_SEC);
    }
    
}