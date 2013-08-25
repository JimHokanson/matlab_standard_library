#include <cstdio>
#include <cstdlib>

#include "MexStdLibSupport.h"

void mexErrMsgTxt(const char*)
{
    fprintf(stderr,"??? Error using method");
    fprintf(stderr,"%s\n",format);
    exit(-1);
}
void mexErrMsgIdAndTxt(const char *errorid,const char* format, ...)
{
    fprintf(stderr,"%s Error using ==> function\n",errorid);
    fprintf(stderr,"%s\n",format);
    exit(-1);
}

void mexWarnMsgIdAndTxt(const char *errorid,const char*format, ...)
{
    fprintf("Warning %s\n",errorid);
    fprintf("%s\n",format);    
}