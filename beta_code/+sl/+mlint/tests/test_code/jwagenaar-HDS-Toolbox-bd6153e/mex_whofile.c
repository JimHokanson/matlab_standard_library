
#include <stdio.h>
#include "mex.h"
#include "mat.h"
#include "matrix.h"

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    char *str;
    /*(void) plhs;      /* unused parameter */
    MATFile *pmat;
    int	  ndir;
    const char **dir;
    int	  i;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    if (!(mxIsChar(prhs[0]))){
	mexErrMsgTxt("Input must be of type string.\n.");
    }

    /* str is the name of the file which is checked */ 
    str = mxArrayToString(prhs[0]);
    
    /* Open the File */
    pmat = matOpen(str, "r");
    if (pmat == NULL) {
      printf("Error opening file %s\n", str);
      return;
    }

    /* Get the variable names inside the file */
    dir = (const char **)matGetDir(pmat, &ndir);
    
    if (dir == NULL) {
      mexPrintf("Error reading directory of file %s\n", str);
      return;
    } 
    
    /* Create output variable */
    plhs[0] = mxCreateCellMatrix((mwSize)ndir, 1);    
    
    for(i = 0; i < ndir; i++)
      mxSetCell(plhs[0], i, mxCreateString(dir[i]));

    mxFree(dir);
    
    /* Close the file */
    if (matClose(pmat) != 0) {
      printf("Error closing file %s\n", str);
      return;
    }
    
    mxFree(str);
} 
