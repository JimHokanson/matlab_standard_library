/*
 * This function was written to be able to go to the current place in the
 * editor where debugging is taking place, by calling a function. Using
 * Matlab code would unfortunately eliminate the ability to pull out 
 * where we are going. See code for more details.
 *
 *  IMPROVEMENTS:
 *  - allow inputs to specify going to the deepest level or 
 *      current level (default)
 *  - put cursor back at command window for quick editing
 *
 */

//Edited in mexopts.sh
//- replaced 10.7 with 10.8
//- added -std=c++11 to the CXXFLAGS
//- renamed file from .c to .cpp
//http://stackoverflow.com/questions/22440523/mex-files-using-xcode-5-1-under-os-x-10-9-with-matlab-2012a
#define char16_t UINT16_T
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )
{
    
	//A better implementation might use mexCallMATLAB
	
    //When displaying the output, instead of assigning to variable, there
    //is a > symbol which indicates which file in the stack is currently
    //active. We only need this one line, then the rest of the code can be
    //Matlab code.
	mexEvalString("DEBUG_STR_UNIQUE_NAME = evalc('dbstack');");
	
	mexEvalString("sl.stack.goDebugHelper(DEBUG_STR_UNIQUE_NAME);");
    
    //Since we create the variable in the caller, we clear it here.
    //Hopefully this variable name was not present before. Note, with 
    //better coding we do all of this in the mex workspace and guarantee
    //that we have no variable name conflicts.
    mexEvalString("clear('DEBUG_STR_UNIQUE_NAME');");
	
	//Example mexCallMATLAB code
   /*
    mexCallMATLAB(1,NULL,0, NULL, "disp");
    
    
    mexCallMATLAB(2, lhs, 1, &x, "eig");
    
    
    mexCallMATLAB(0,NULL,1, &lhs[1], "disp");
    
    
    invertd(mxGetPr(lhs[1]), mxGetPi(lhs[1]));
    
    mexCallMATLAB(0,NULL,1, &lhs[1], "disp");
    */
}