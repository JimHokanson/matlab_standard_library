#include "MexDataTypes.h"
#include "mex.h"
#include "matrix.h"
using namespace MexSupport;
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) 
{    
    mexPrintf("BUILTIN TYPES  =======\n");
    mexPrintf("mwSize:            %d\n",sizeof(mwSize));
    mexPrintf("mxChar:            %d\n",sizeof(mxChar));
    mexPrintf("mxChar:            %d\n",sizeof(L'a'));
    mexPrintf("\n");
    mexPrintf("CANONICAL TYPES  =======\n");
    mexPrintf("sizeof<char>:      %d\n", sizeof(char));
    mexPrintf("sizeof<short>:     %d\n", sizeof(short));
    mexPrintf("sizeof<int>:       %d\n", sizeof(int));
    mexPrintf("sizeof<long>:      %d\n", sizeof(long));
    mexPrintf("sizeof<long long>: %d\n", sizeof(long long));
    mexPrintf("sizeof<float>:     %d\n", sizeof(float));
    mexPrintf("sizeof<double>:    %d\n", sizeof(double));
    mexPrintf("\n");
    mexPrintf("MEXSUPPORT TYPES ==============\n");
    mexPrintf("sizeof<MexInt8>:   %d\n", sizeof(MexInt8));
    mexPrintf("sizeof<MexUInt8>:  %d\n", sizeof(MexUInt8));
    mexPrintf("sizeof<MexInt16>:  %d\n", sizeof(MexInt16));
    mexPrintf("sizeof<MexUInt16>: %d\n", sizeof(MexUInt16));
    mexPrintf("sizeof<MexInt32>:  %d\n", sizeof(MexInt32));
    mexPrintf("sizeof<MexUInt32>: %d\n", sizeof(MexUInt32));
    mexPrintf("sizeof<MexInt64>:  %d\n", sizeof(MexInt64));
    mexPrintf("sizeof<MexUInt64>: %d\n", sizeof(MexUInt64));
    mexPrintf("\n");
    mexPrintf("sizeof<MexFloat>:  %d\n", sizeof(MexFloat));
    mexPrintf("sizeof<MexDouble>: %d\n", sizeof(MexDouble));
    mexPrintf("\n");
    mexPrintf("MEX CLASSIDS==============\n");
    mexPrintf("logical  %d\n",mxLOGICAL_CLASS);
    mexPrintf("char     %d\n",mxCHAR_CLASS);
    mexPrintf("double   %d\n",mxDOUBLE_CLASS);
    mexPrintf("single   %d\n",mxSINGLE_CLASS);
    mexPrintf("int8     %d\n",mxINT8_CLASS);
    mexPrintf("uint8    %d\n",mxUINT8_CLASS);
    mexPrintf("int16    %d\n",mxINT16_CLASS);
    mexPrintf("uint16   %d\n",mxUINT16_CLASS);
    mexPrintf("int32    %d\n",mxINT32_CLASS);
    mexPrintf("uint32   %d\n",mxUINT32_CLASS);
    mexPrintf("int64    %d\n",mxINT64_CLASS);
    mexPrintf("uint64   %d\n",mxUINT64_CLASS);
    mexPrintf("cell     %d\n",mxCELL_CLASS);
    mexPrintf("struct   %d\n",mxSTRUCT_CLASS);
    mexPrintf("unknown  %d\n",mxUNKNOWN_CLASS);
    mexPrintf("function %d\n",mxFUNCTION_CLASS);
    mexPrintf("void     %d\n",mxVOID_CLASS);
    return;
}
