function ekeyboard_helper()

% anObj is from the calling_function_info class

   function my_callback_fcn(~,~)
        myObj= sl.stack.calling_function_info(4) %gets the caller of ekeyboard. should be 4 as arg? need to test
        if isnan(myObj.line_number)
            % is there a way to find where ekeyboard is in that file?
            myObj.line_number=1;
        end
        matlab.desktop.editor.openAndGoToLine(myObj.file_path,myObj.line_number);
    end


%{
  Notes on using timers:
  "When you create a callback function, the first two arguments must be a 
  handle to the timer object and an event structure. An event structure 
  contains two fields: Type and Data. The Type field contains a text string 
  this field can be any of the following strings: 'StartFcn', 'StopFcn',
  'TimerFcn', or 'ErrorFcn'. The Data field contains the time the event 
  that identifies the type of event that caused the callback. The value of 
  occurred." (~obj ~event in the above function)
%}

% see http://www.mathworks.com/help/matlab/matlab_prog/creating-a-function-handle.html
% http://www.mathworks.com/help/matlab/matlab_prog/timer-callback-functions.html


t=timer('ExecutionMode','singleShot'); % creates a timer
set(t,'StartDelay',0.5); % sets a short delay

%sets primary timer functionality
t.TimerFcn = {@my_callback_fcn}; 

start(t);

% delete(t);      will need to figure out how to delete the timer. see ekeyboard.m
end
