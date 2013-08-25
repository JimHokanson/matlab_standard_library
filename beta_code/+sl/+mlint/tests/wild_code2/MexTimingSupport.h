#ifndef MEX_TIMING_SUPPORT
#define MEX_TIMING_SUPPORT
#include <ctime>

namespace MexSupport{
    clock_t tic();
    
    void toc();
    
    void toc(clock_t&);
};
#endif