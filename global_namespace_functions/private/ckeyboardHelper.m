function ckeyboardHelper()
%
%   This function is called by ckeyboard(). This function launches a timer
%   which opens the editor to the appropriate file after the keyboard()
%   command has been issued. It also returns the focus back to the command
%   window.
%

%No inputs gets caller, this also skips the mex call and goes straight
%to the .m file. That's not a feature of the function we're calling, but
%rather how Matlab does - or rather doesn't - expose the mex functions
%to the stack
obj = sl.stack.calling_function_info();

t = timer('ExecutionMode','singleShot');

%The delay needs to be sufficient to let the keybaord launch and for 
%any focus to get set to the command window. It can't be too long otherwise
%it will seem out of place. 0.5s seems to work ok
set(t,'StartDelay',0.5);

t.TimerFcn = @(~,~)h__callback_function(obj.file_path,obj.line_number,t);

start(t);

end

function h__callback_function(file_path,line_number,timer)
    % We really want to only open the editor to the line, but to leave
    % focus at the command window
   matlab.desktop.editor.openAndGoToLine(file_path,line_number);
   sl.ml.cmd_window.grabFocus();
   stop(timer)
   delete(timer)
end
