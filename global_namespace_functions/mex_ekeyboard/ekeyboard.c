#include "mex.h"

/*
Compile via:

	mex ekeyboard.c

 */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
	//This function will initialize and run a timer that moves
	//the focus to the correct location
	mexCallMATLAB(0,NULL,0,NULL,"ekeyboardHelper");
	
	//This works, unlike evalin('caller','keyboard') in a .m file
	//which doesn't put the user in the correct workspace
    mexEvalString("keyboard");
}
