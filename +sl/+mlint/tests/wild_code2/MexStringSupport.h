#ifndef MEX_STRING_SUPPORT_H
#define MEX_STRING_SUPPORT_H
#include "MexSupport.h"
#include "MexDataTypes.h"


namespace  MexSupport {
    
    // @brief copy matlab string to a c-style string
    // User is responsible for deallocating 'dest' appropriately
    // @param src pointer to matlab string
    // @param dest destination buffer, will be reallocated
    
    void copyFromMxString(const mxArray* src, char*& dest);
    
    void copyToMxString(const char* src, mxArray*& dest);
    
    void assignToMxString(mxChar* str, mxArray*& dest);
    
    void convertStringToFieldName(char*& str);
    
    void printstr(const mxChar* str);
        
    MexInt32 strlen16(const mxChar* str);
    
    mxChar* strrchr16(const mxChar* str, mxChar c);

    mxChar* strchr16(const mxChar* str, mxChar c);
};
#endif
