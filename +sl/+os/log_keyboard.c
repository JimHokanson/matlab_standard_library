//http://stackoverflow.com/questions/1437158/c-win32-keyboard-events
//
//
//      mex log_keyboard.c

#include "mex.h"
#include <windows.h>

char str[80];

bool shift_pressed;
bool ctrl_pressed;
bool caps_pressed;

LRESULT CALLBACK keyboard_hook_procedure(int code, WPARAM wParam, LPARAM lParam) {
    //
    //  https://msdn.microsoft.com/en-us/library/windows/desktop/ms644985(v=vs.85).aspx
    //
    //  code :
    //      Determines how to process the message. If less than zero
    //      you must call CallNextHookEx
    //  wParam : 
    //      - WM_KEYDOWN
    //      - WM_KEYUP
    //      - WM_SYSKEYDOWN - alt key pressed
    //      - WM_SYSKEYUP
    //  lParam :
    //      pointer to a KBDLLHOOKSTRUCT structure
    //      Structure defined at:
    //          https://msdn.microsoft.com/en-us/library/windows/desktop/ms644967(v=vs.85).aspx
    //     typedef struct tagKBDLLHOOKSTRUCT {
    //               DWORD     vkCode; - https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
    //               DWORD     scanCode; - hardware scan code for key
    //               DWORD     flags;
    //               DWORD     time; - timestamp of the message
    //               ULONG_PTR dwExtraInfo; - Additional information associated with the message.
    
    
    
//    } KBDLLHOOKSTRUCT, *PKBDLLHOOKSTRUCT, *LPKBDLLHOOKSTRUCT;
//         short shift_pressed = GetKeyState(VK_SHIFT);
//     short ctrl_pressed = GetKeyState(VK_CONTROL);
//     short caps_pressed = GetKeyState(VK_CAPITAL);

    
    KBDLLHOOKSTRUCT*  kbd = (KBDLLHOOKSTRUCT*)lParam;
    
    bool key_pressed;
    
    DWORD vkcode = kbd->vkCode;
    
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
    
    //wParam
    
//     if (wParam == WM_KEYUP){
//         key_pressed = False;
//     }else if (wParam == WM_KEYDOWN){
//         key_pressed = True;
//     }else
//     {
//     	return CallNextHookEx(NULL, code, wParam, lParam); 
//     }
   
    if (wParam == WM_KEYUP || wParam == WM_KEYDOWN){
        //GetKeyState
        //Shift
        //Ctrl
        //Caps Lock
        key_pressed = !(wParam == WM_KEYUP);
        
        //This doesn't handle sticky keys ...
        //Added to ensure we don't miss capital letters ...
        if (vkcode == VK_LSHIFT || vkcode == VK_RSHIFT){
            shift_pressed = key_pressed;
        }else if (vkcode == VK_LCONTROL || vkcode == VK_RCONTROL){
            ctrl_pressed = key_pressed;
        }else if (vkcode == VK_CAPITAL){
            caps_pressed = key_pressed;
        }
        
        
        //I'm not sure of a better way to pass parameters ... :/
        sprintf(str,"sl.os.keyboard_logger.keyboardEvent('%d:%d:%d:%d:%d:%d:%d')\0",
                key_pressed,kbd->vkCode,kbd->scanCode,kbd->time,
                shift_pressed,ctrl_pressed,caps_pressed);
        mexEvalString(str);
    }
    
// // // //     //if (wParam == WM_KEYUP){
// // // //         //sprintf should add a terminating null character to terminate the string
// // // //         //thus I don't think we need to worry if the size of this string varies ...
// // // //         
// // // //         //Keys to know
// // // //         //Shift
// // // //         //Ctrl
// // // //         //caps lock
// // // //         //Alt
// // // //     
// // // //         BYTE keyState[256];
// // // //         
// // // //         GetKeyboardState((LPBYTE)&keyState);
// // // //         wchar_t keyBuf[10];
// // // //         int status = ToUnicodeEx(kbd->vkCode, kbd->scanCode, keyState, keyBuf, 10, 0 , hkl);
// // // //     
// // // //         if (status == 1 && keyBuf[0] > 0){
// // // //             sprintf(str,"sl.os.keyboard_logger.keyboardEvent('%d:%d:%g')\0",wParam,keyBuf[0],kbd->time);
// // // //             //This is a blocking call ...
// // // //             //TODO: It would be better to not block ...
// // // //             mexEvalString(str);
// // // //         }
// // // //     //}

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

    //  https://msdn.microsoft.com/en-us/library/windows/desktop/ms644990(v=vs.85).aspx
    //  1) WH_KEYBOARD_LL: Installs a hook procedure that monitors low-level keyboard input events.
    //  2) HOOKPROC - pointer to the hook procedure
    //  3) HINSTANCE - a handle to the dll containing the hook procedure - set
    //          to NULL if it comes from within code associated with the current
    //          process
    //  4) DWORD = the identifier of the thread with which the hook
    //      procedure is to be associated
    //      => I think this allows you to be more specific as to what
    //      you are listening to
    if (keyboard_hook == 0){
        
            shift_pressed = GetKeyState(VK_SHIFT) < 0;
            ctrl_pressed = GetKeyState(VK_CONTROL) < 0;
            caps_pressed = GetKeyState(VK_CAPITAL) == 1;
        
        keyboard_hook = SetWindowsHookEx(
                      WH_KEYBOARD_LL,      
                      keyboard_hook_procedure,    
                      NULL,            
                      0);
    }

    mexAtExit(CloseStream);

}
