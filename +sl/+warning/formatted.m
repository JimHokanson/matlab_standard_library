function varargout = formatted(message_str,varargin)
%x  Create a formatted warning with a link to the calling method.
%
%   Calling forms:
%   --------------
%   sl.warning.formatted(message_str,**formatting_option_inputs)
%   
%   formatted_warning_str = sl.warning.formatted(message_str)
%
%   Summary:
%   --------
%   The default behavior with no output argument is to print a warning
%   of the form:
%
%       [WARNING <file>:<line> ] <message>
%
%   With a link to the to line where the call came from.
%
%   If an output is requested the display is quenched.
%
%   Inputs:
%   -------
%   message_str : string
%       The warning message to print. It can also be a formatting string.
%       See the examples for clarification.
%   formatting_option_inputs : 
%       When these are passed in the final warning message is computed via
%       sprintf as:
%           messageStr = sprintf(message_str,formatting_option_inputs{:});
%
%   Outputs:
%   --------
%   formatted_warning_str
%
%   Examples:
%   ---------
%   sl.warning.formatted('Surprisingly low channel count: %d',channel_count)
%
%   sl.warning.formatted('This code branch is in beta testing')
%
%   str = sl.warning.formatted('When does this code run???')
%
%   Improvments:
%   ------------
%   Implement word wrapping function
%   http://www.mathworks.com/matlabcentral/fileexchange/9909-line-wrap-a-string/content//linewrap.m
%   - above link doesn't honor links ...

if nargin > 1
    message_str = sprintf(message_str,varargin{:});
end


%CODE STRING
%------------------------
info = sl.stack.calling_function_info;

link_txt = sprintf('%s.m:%d',info.name,info.line_number);
% check if java is enabled ( it is usually on ), if it is print a nice link 
% to the code, otherwise print the raw text.

if usejava('desktop')
    link_str = sl.str.create_clickable_cmd.openFileToLine(info.file_path,info.line_number,link_txt);
    %link_str = sl.ml.cmd_window.createOpenToLineLink(info.file_path,info.line_number,link_txt);
else
    link_str = link_txt;
end
%---------------------------------------------------

warning_str = sprintf('[WARNING %s] %s', link_str, message_str);
if nargout < 1
    %NotifierManager.notify('warning',warning_str);
    fprintf(2,'%s\n',warning_str);
else
    varargout{1} = warning_str;
end
