function str = id(mnemonic)
%
%   str = sl.error.id(mnemonic)
%
%   Returns an error identifier for a function given a mnemonic.
%
%   Example:
%   From myFunction with mnemonic 'failedLookup' yields:
%
%   str => myFunction:failedLookup
%
%   See Also:
%   lasterror
%   

%http://www.mathworks.com/help/matlab/matlab_prog/capture-information-about-errors.html#bq9tdlq-1
%1) No white space
%2) First character must be alphabetic
%3) Remaining characters alphanumeric or underscore

info = sl.stack.calling_function_info();

str = info.name;

%'.' -> ':'
str = [strrep(str,'.',':') ':' mnemonic];
