function n_chars_max = getMaxCharsBeforeScroll()
%
%
%    n_chars_max = sl.ml.cmd_window.getMaxCharsBeforeScroll
%
%    Returns the maximum # of characters that can be displayed
%    in the command window before scrolling will occur
%
%    ??? Does this change if the font size changes?????
%
%

%TODO: Allow version checking and using:
%matlab.desktop.commandwindow.size

%From root properties documentation:
%            CommandWindowSize
% [columns rows]
%
% Note:   The CommandWindowSize root property will be removed in a future
% release. To determine the number of columns and rows that display in the
% Command Window, given its current size, call
% matlab.desktop.commandwindow.size. Current size of command window. Size
% of the MATLAB® command window, in a two-element vector. The first element
% is the number of columns wide and the second element is the number of
% rows tall.
%
% For example, a value of [50,25] means that 50 characters can display
% across the Command Window, and 25 lines can display without scrolling.
%
% Enabling the Command Window Display preference Set matrix display width
% to eighty columns forces the returned value for number of columns wide to
% be 80 regardless of the window width.

cmd_win_sizes = get(0,'CommandWindowSize');
%Has 2 elements:
%1) # of chars for width
%2) # of lines????

n_chars_max = cmd_win_sizes(1)-1; %NOTE: If we don't use -1 then
%the scroll bar will appear (at least in 2014a)
end