function ekeyboard()
%x Refocus to the editor window after calling keyboard()
%
% ekeyboard.m
% Greg Goldman
% 
% Calling Forms:
% -------------
% 1) ekeyboard()
% 
% inputs:
% -----------
% 
%
% Improvements:
% ------------
% 1) It would be nice to return the focus to the exact position within a
% line that was previously the focus. Currently, it simply highlights the
% whole line. I believe this would require editing of the openAndGoToLine
% function in editor.m (TODO, more on this at a later time)
%
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

%------------------------------------------

% call the mex function
ekeyboard
% delete the timer at some point... maybe use delete(timerfind) after a pause. Probably best way

end
