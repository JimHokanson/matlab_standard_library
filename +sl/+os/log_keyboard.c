//http://stackoverflow.com/questions/1437158/c-win32-keyboard-events
//mex log_keyboard.c

#include "mex.h"
#include <windows.h>

char str[80]

LRESULT CALLBACK keyboard_hook_procedure(int code, WPARAM wParam, LPARAM lParam) {
    //
    //  https://msdn.microsoft.com/en-us/library/windows/desktop/ms644985(v=vs.85).aspx
    //
    //  code :
    //  wParam : 
    //      - WM_KEYDOWN
    //      - WM_KEYUP
    //      - WM_SYSKEYDOWN
    //      - WM_SYSKEYUP
    //  lParam :
    //      pointer to a KBDLLHOOKSTRUCT structure
    //      https://msdn.microsoft.com/en-us/library/windows/desktop/ms644967(v=vs.85).aspx
    //     typedef struct tagKBDLLHOOKSTRUCT {
    //               DWORD     vkCode; - https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
    //               DWORD     scanCode; - hardware scan code for key
    //               DWORD     flags;
    //               DWORD     time; - timestamp of the message
    //               ULONG_PTR dwExtraInfo; - Additional information associated with the message.
    //    } KBDLLHOOKSTRUCT, *PKBDLLHOOKSTRUCT, *LPKBDLLHOOKSTRUCT;
    
    KBDLLHOOKSTRUCT*  kbd = (KBDLLHOOKSTRUCT*)lParam;
    
    //WARNING:
    //--------
    //The hook procedure should process a message in less time than the data 
    //entry specified in the LowLevelHooksTimeout value in the following registry key:
    //      HKEY_CURRENT_USER\Control Panel\Desktop
    // The value is in milliseconds. If the hook procedure times out, the system 
    // passes the message to the next hook. However, on Windows 7 and later, 
    // the hook is silently removed without being called. There is no way 
    // for the application to know whether the hook is removed.
      
    //  This hook must call the next one ...
    //  CallNextHookEx
    // https://msdn.microsoft.com/en-us/library/windows/desktop/ms644974(v=vs.85).aspx
    //
    //  0 means, just call the next one ...
    if (code < 0){
        return CallNextHookEx(NULL, code, wParam, lParam);
    }
    
    if (wParam == WM_KEYUP){
        //This works
        mexEvalString("sl.os.wtf_callback");
        //mexEvalString(sprintf("sl.os.wtf_callback('%d:%d')",wParam,kbd->vkCode));
    }
    
    //mexPrintf("Next ------\n");
    //mexPrintf("vkCode: %d\n",kbd->vkCode);
    //This forces a flush ...
    //mexEvalString("disp('     ')");
    

   return CallNextHookEx(NULL, code, wParam, lParam);	
}

HHOOK keyboard_hook = 0;

static void CloseStream(void)
{
    if (keyboard_hook != 0){
        UnhookWindowsHookEx(keyboard_hook);
    }
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) 
{
    //Entry points
    //------------
    //1) Initialize
    //2) Clear

    //https://msdn.microsoft.com/en-us/library/windows/desktop/ms644990(v=vs.85).aspx
    //1) WH_KEYBOARD_LL: Installs a hook procedure that monitors low-level keyboard input events.
    //2) HOOKPROC - pointer to the hook procedure
    //3) HINSTANCE - a handle to the dll containing the hook procedure - set
    //          to NULL if it comes from within code associated with the current
    //          process
    //4) DWORD = the identifier of the thread with which the hook
    //      procedure is to be associated
    //      => I think this allows you to be more specific as to what
    //      you are listening to
    if (keyboard_hook == 0){
        keyboard_hook = SetWindowsHookEx(
                      WH_KEYBOARD_LL,      
                      keyboard_hook_procedure,    
                      NULL,            
                      NULL);
    }

    mexAtExit(CloseStream);

}
