#include "MexStringSupport.h"
#include "mex.h"
#include "matrix.h"
#include <cstring>

using namespace std;

namespace MexSupport{
    void copyFromMxString(const mxArray* src, char*& dest) {
        if(dest != 0x0)
            mxFree(dest);
        
        dest = 0x0;
        if(!mxIsChar(src)) {
            mexErrMsgTxt("Attempting to copy an invalid string");
        }
        
        int len = mxGetNumberOfElements(src);
        // need to add 1 to string length to capture terminator
        dest = (char*)mxRealloc(dest, sizeof(char)*(len+1));
        mxGetString(src, dest, len+1);
    }
    
    void copyToMxString(const char* src, mxArray*& dest) {
        if(dest != 0x0) {
            mxDestroyArray(dest);
            dest = 0x0;
        }
        dest = mxCreateString(src);
    }
    
    void assignToMxString(mxChar* str, mxArray*& dest) {
        
        if(dest != 0x0) {
            mxDestroyArray(dest);
            dest = 0x0;
        }
        
        mwSize* dims = (mwSize*)mxMalloc(sizeof(mwSize)*2);
        // create an initially empty string matrix
        dims[0] = 0;
        dims[1] = 0;
        dest = mxCreateCharArray(2, dims);
        // now set the data adjust the dimensions
        mxSetData(dest, str);
        // CAA it is unclear to me whether the string length should
        // include the terminator... mxGetNumberOfElements will not
        // include it so I suppose I should not either
        dims[0] = 1;

        dims[1] = strlen16(str);
        // set the proper dimensions
        mxSetDimensions(dest, dims, 2);
        
        // Dims are deep copied within mxSetDimensions therefore it is ok
        // to free
        mxFree(dims);
        
    }
    void convertStringToFieldName(char*& str)
    {
        int N = strlen(str);
        bool trim_first = false;
        bool trim_last  = false;
        char replacement = '_';
        for(int ii = 0; ii < N; ii++)
        {
            bool is_num   = false;
            bool is_alpha = false;
            MexUInt8 this_char = static_cast<MexUInt8>(str[ii]);
            
            // determine character class
            is_num   =  this_char >= 48 && this_char <= 57;
            if( !is_num)
            {
                is_alpha = (this_char >= 65 && this_char <= 90) \
                        || (this_char >= 97 && this_char <= 122);
            }
            
            if(ii == 0 && !is_alpha)
            {
                // special rules for first character,
                trim_first = true;
            }
            else if((ii == N-1) && !(is_alpha || is_num))
            {
                // special rules for last character,
                trim_last = true;
            }
            else if( !is_alpha && !is_num)
            {
                str[ii] = replacement;
            }
        }
        if(trim_first)
        {
            str++;
            N--;
        }
        
        if(trim_last)
        {
            N--;
        }
        if(trim_first || trim_last)
        {
            str = (char*)mxRealloc(str,sizeof(char)*(N+1));
            str[N] = '\0';
        }
        return;
    }

    void printstr(const mxChar* str) {
        const mxChar* iter = str;
        mxChar term  = static_cast<mxChar>(0);
        
        while(*iter != term) {
            mexPrintf("%c", static_cast<char>(*iter));
            iter++;
        }
    }
    
    MexInt32 strlen16(const mxChar* str) {
        const mxChar* iter = str;
        mxChar term  = static_cast<mxChar>(0);
        while(*iter != term)
            iter++;
        return iter - str;
    }
    
    mxChar*  strchr16(const mxChar* str, mxChar c) {
        const mxChar* iter = str;
        mxChar term  = static_cast<mxChar>(0);
        while(*iter != term && *iter != c)
            iter++;
        
        return const_cast<mxChar*>(iter);
    }
    
    mxChar*  strrchr16(const mxChar* str, mxChar c) {
        const mxChar* iter = str+strlen16(str);
        mxChar term  = static_cast<mxChar>(0);
        while(iter != str && *iter != c)
            iter--;
        // nullify iter if it hit the start of the string without finding the
        // character
        if( *iter != c)
            iter = 0x0;
        
        return const_cast<mxChar*>(iter);
    }
    
//     vector<mxChar*> strsplit16(const MexChar*& str, MexChar split_char) {
//         // find split points
//         mxChar* ret = str;
//         vector<mxChar*> split_points;
//         while(ret != 0x0) {
//             ret = strchr16(ret, split_char);
//             if (ret += 0x0) {
//                 split_points.push_back(ret);
//                 ret++;
//             }
//         }
//         if(split_points.back() - str != strlen16(str))
//             split_points.push_back(str + strlen16(str));
//         
//         vector<mxChar*> str_segments;
//         mxChar* last_split = str;
//         int offset = 1;
// 
//         vector<mxChar*>::const_iterator split_iter = split_points.begin();
//         mxChar term  = static_cast<mxChar>(0);
//         for(; split_iter != split_points.end(); split_iter++) {
//             mxChar* this_split = *split_iter;
//             
//             int N = this_split - last_split;
//             if( *last_split == split_char)
//                 offset = 1;
//             else
//                 offset = 0;
//             
//             if( N >  0) {
//                 N -= offset;
//                 mxChar* output_str = (mxChar*)mxMealloc(output_str, sizeof(mxChar)*(N+1));
//                 memcpy(output_str, last_split+offset, N);
//                 output_str[N] = term;
//             }
//             last_split = this_split;
//         }
//         return str_segments;
//     }
};
