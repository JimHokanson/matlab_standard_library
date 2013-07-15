function varargout = formatted(message_str,varargin)
%formatted  Create a formatted warning with a link to the calling method
%
%   sl.warning.formatted(message_str,format_str)
%   
%   formatted_warning_str = sl.warning.formatted(message_str)
%
%   Prints a warning with an open to link link in the form of
%   [WARNING <file>:<line> ] <message>
%
%   If an output is requested display is quenched.
%
%
% tags: text, display
% see also: getCallingFunction, createOpenToLineLink, displayCallStack

if nargin > 1
    messageStr = sprintf(message_str,varargin{:});
end


%CODE STRING
%------------------------
info = sl.stack.getCallingFunction;

link_txt = sprintf('%s.m:%d',info.name,info.line);
% check if java is enabled ( it is usually on ), if it is print a nice link 
% to the code, otherwise print the raw text.

if usejava('desktop')
    link_str = sl.cmd_window.createOpenToLineLink(file,line,link_txt);
else
    link_str = link_txt;
end
%---------------------------------------------------

warning_str = sprintf('[WARNING %s] %s', link_str, messageStr);
if nargout < 1
    NotifierManager.notify('warning',warning_str);
else
    varargout{1} = warning_str;
end
