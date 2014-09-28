// Typedef basic data types to ease support of 32/64 bit OSes
// This is not supported by Windows so need to case include

#ifdef RNEL_IS_MAC
    #include <stdint.h>
#elif RNEL_IS_UNIX
    #include <stdint.h>
#else
    // Starting With MSVC 2010 (or so) stdint was added
    #if _MSC_VER >= 1600
        #include <stdint.h>
    #else
        // CAA TODO: is this a MINI_GW issue?
        #include "pstdint.h"
    #endif
#endif
        
namespace MexSupport{
    typedef int8_t             MexInt8;
    typedef uint8_t            MexUInt8;
    typedef int16_t            MexInt16;
    typedef uint16_t           MexUInt16;
    typedef int32_t            MexInt32;
    typedef uint32_t           MexUInt32;
    typedef int64_t            MexInt64;
    typedef uint64_t           MexUInt64;
    
    typedef float              MexFloat;
    typedef double             MexDouble;
};