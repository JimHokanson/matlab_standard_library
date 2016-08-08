%x Goes to the editor at the current debug location.
%
%   Call this function to go to the editor file which is currently being
%   debugged (has green arrow).
%
%   This is a mex function because a mex function doesn't change the
%   debuggable execution stack. In other words, if we called a regular
%   function to try and perform this task, the regular function would steal
%   the information we need, as it would become the currently
%   debugged/executing function.
%
%   A slower alternative which this is avoiding is the following:
%   1) dbstack()
%   2) clicking on the link that is displayed in dbstack

error('Please compile goDebug mex code')