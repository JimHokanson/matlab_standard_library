#include "mex.h"

/*
Compile via:

	mex ckeyboard.c

 */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
	//This function will initialize and run a timer that moves
	//the focus to the correct location
	mexCallMATLAB(0,NULL,0,NULL,"ckeyboardHelper");
	
	//This works, unlike evalin('caller','keyboard') in a .m file
	//which doesn't put the user in the correct workspace
    mexEvalString("keyboard");
}
