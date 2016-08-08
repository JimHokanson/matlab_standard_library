#include "mex.h"

/*
 >> edit([matlabroot '/extern/examples/mex/mexcallmatlab.c']); type into command line for help

 TODO: Rename to ekeyboard.c so that we can access this code via ekeyboard DONE!(I think)
 
//Compile via:
mex ekeyboard.c
 must have a MinGW-w64 C/C++ compiler installed!
 */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    
    //TODO: Run a mexcallmatlab line which calls a helper function => ekeyboard_helper (place in its own .m file)
    //that initializes and runs the timer
    //http://www.mathworks.com/help/matlab/apiref/mexcallmatlab.html
    mexCallMATLAB(0,NULL,0,NULL,"ekeyboard_helper");
    // this will need arguments, specifically at last a calling_function_info(??)
    
    //This works, unlike evalin('caller','keyboard') in a .m file
    mexEvalString("keyboard");
    
}
