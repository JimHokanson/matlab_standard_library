function runInFunction(function_name)
%
%   
%   sl.test.runInFunction(function_name)
%
%
%   IN PROGRESS
%
%
%   @TEST_CODE
%
%   First example:
%   sl.path.asCellstr

%Questions:
%These tests also function as examples.
%

%{
- Most examples are tests

%}

%Problems:
%1) Text code is not syntax highlighted ...
%       - subfunction with @TEST_CODE   @END_TEST_CODE?
%       - what to do for functions in classes
%           - perhaps allow false
%2) Finding these tests can be slow as they require reading
%   the file to know that they exist

%RULES???
%{
1) The symbol @TEST_CODE should be located in a group comment block


%}

keyboard

s = which(function_name);
%TODO: Check if defined
%NOTE: Might be a function here ...

str = fileread(s);
str(str == char(13)) = '';
[start_I,end_I] = regexp(str,'%{\n@TEST_CODE.*?%}','start','end','once');

%TODO: Check on start_I existing

%TODO: Improve this ...
code = strtrim(str(start_I+13:end_I-2));

%What functionality do I want here?
%
%Try/Catch


end

% function helper__runCode(code_string_to_run)
%    
% 
% end