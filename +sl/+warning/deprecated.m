function deprecated(old_file_name, new_file_name, reason_str)
%deprecated  Displays a warning about deprecated functionality
%
%   sl.warning.deprecated(*oldFile, *newFile, *reason)
%
%   Warns the user about accessing a deprecated function
%   [WARNING <file>:<line> ] <message>
%
%   INPUTS
%   =======================================================================
%   old_file_name : (char, default: name of calling function), file being 
%               deprecated (for display purposes only), caller info
%               is used to provide a link
%   new_file_name : (char, default: '') new version of deprecated file
%   reason_str    : (char,  default '') reason for deprecation
%
%   
%   IMPROVEMENTS
%   ------------
%   1) Link to the caller of the caller, not the caller - maybe just do a
%   stack dump
%
%   EXAMPLE
%   =======================================================================
%   Called from some function:
%   sl.warning.deprecated('','getDirectoryTree.m','Chris'' code is better than Jim''s')
%
%   tags: text, display
%
%   See Also: 
%   sl.warning.formatted
%   sl.stack.calling_function_info

info = sl.stack.calling_function_info(2);

if nargin < 1 || isempty(old_file_name)
    old_file_name = info.name;
end

%Display string construction
%--------------------------------------------------------------------------
source_str = sprintf('The function ''%s'' is being deprecated',old_file_name);

if nargin >= 2 && ~isempty(new_file_name)
   in_favor_of_str = sprintf(' in favor of ''%s''',new_file_name);
else
   in_favor_of_str = ''; 
end

if nargin == 3
    reason_str = sprintf('\nReason\n\t%s',reason_str);
else
    reason_str = '';
end

display_str = [source_str in_favor_of_str '. Please change your code' reason_str];

% Note: Cant call formattedWarning here because it will get the line and
% file wrong.
link_txt = sprintf('%s.m:%d',info.name,info.line_number);
if usejava('desktop')
    link_str = sl.cmd_window.createOpenToLineLink(info.file_path,info.line_number,link_txt);
else
    link_str = link_txt;
end
fprintf(2,'[WARNING %s ] %s\n', link_str, display_str);
