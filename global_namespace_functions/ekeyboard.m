function ekeyboard(TimeAmount)
%x Refocus to the editor window after calling keyboard()
%
% ekeyboard.m
% Greg Goldman
% 
% Calling Forms:
% -------------
% 1) ekeyboard(TimeAmount)
%
% 2) ekeyboard()
%
% This function exists because the *keyboard()* function changes the 
% focus to the command window after debugging when it may be preferable
% to focus on the editor window. This function solves this.
% ekeyboard requires the input of a given amount of time
% 
% inputs:
% -----------
% TimeAmount: an optional numeric value that defines how long the timer 
%   should wait after debugging is finished to refocus the cursor. If left
%   undefined, it is automatically set to 0.05 seconds
%
% Improvements:
% ------------
% 1) It would be nice to return the focus to the exact position within a
% line that was previously the focus. Currently, it simply highlights the
% whole line. I believe this would require editing of the openAndGoToLine
% function in editor.m (TODO, more on this at a later time)
%
% 2) It seems this function could exist without the use of a timer assuming
% the user doesn't want to wait any additional time after finishing
% debugging to return focus to the editor window. Timer may use unnecessary
% computing power/time 
%
% 3) Possibility of changing TimeAmount from the debugger? Allow user to
% change delay while in debugger if something else comes up...
%
% Usage/examples:
% ---------------
% Use the ekeyboard() function in a script where you would like to debug.
% K>> will appear in the command window indicating debug mode. Use dbcont()
% to exit debug mode when finished and to continue running of the calling
% script. 
%
% See other operational comments below which consider some other
% issues/options


if nargin==0 % sets the default time
        %disp('default timer set to .01 seconds.')     was here for testing
        TimeAmount=.01;
end

%gets sl.ml.editor  to interface with the editor API
e=sl.ml.editor.getInstance();

% gets the active document sl.ml.editor.document
myDoc=e.getActiveDocument(); 

currFile=e.active_filename; 
myStarting=myDoc.selection_start_row;

% the callback function that changes the focus to the editor window (timer)
    function my_callback_fcn(~,~, currFile, myStarting)
        matlab.desktop.editor.openAndGoToLine(currFile,myStarting);        
    end

% a start function which could call keyboard. I don't think this works 
% because opening debugger (calling keyboard()) doesn't stop timers.
% Therefore, you can't call keyboard from within the timer effectively. 
% Leaving this here in case of future need.
%{
    function my_start_fcn(~,~)
        evalin('caller','keyboard()');        
    end
%}

%{
Notes on using timers:
"When you create a callback function, the first two arguments must be a 
handle to the timer object and an event structure. An event structure 
contains two fields: Type and Data. The Type field contains a text string 
that identifies the type of event that caused the callback. The value of 
this field can be any of the following strings: 'StartFcn', 'StopFcn',
'TimerFcn', or 'ErrorFcn'. The Data field contains the time the event 
occurred." (~obj ~event in the above function)
%}

% see http://www.mathworks.com/help/matlab/matlab_prog/creating-a-function-handle.html
% http://www.mathworks.com/help/matlab/matlab_prog/timer-callback-functions.html

t=timer('ExecutionMode','singleShot'); % creates a timer
set(t,'StartDelay',TimeAmount); % sets a short delay

%t.StartFcn = {@my_start_fcn}; 
% see comment above for function my_start_fcn. Unsure if necessary^

%sets primary timer functionality
t.TimerFcn = {@my_callback_fcn, currFile, myStarting}; 

% calls keyboard in the caller workspace *not in the base, 
% which doesn't seem to work
evalin('caller', 'keyboard()'); %use dbcont() to continue. 

start(t);
pause(TimeAmount+0.01) %lets the timer finish before deleting it
delete(t);

end