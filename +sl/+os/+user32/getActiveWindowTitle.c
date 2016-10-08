
//  mex getActiveWindowTitle.c
//  sl.os.user32.getActiveWindowTitle()

/*
 
for i = 1:10
 sl.os.user32.getActiveWindowTitle()
 pause(1) 
end
 
 
 
 
 */

#include "mex.h"
#include <windows.h>
#include <string.h>

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) 
{
    
    if(nlhs > 1){ 
        mexErrMsgIdAndTxt( "getActiveWindowTitle:maxlhs", "Too many output arguments.");
    }
    
    char *title;
    
    title = mxCalloc(1,256);
            
    HWND handle = GetForegroundWindow();
    if (handle)
    {
        GetWindowText(handle, title, 256);
    }
    else
    {
        strcpy(title,"error: No Window Found");
    }

    plhs[0] = mxCreateString(title);
}