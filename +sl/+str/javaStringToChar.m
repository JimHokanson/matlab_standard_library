function matlab_str = javaStringToChar(java_string)
%
%
%   matlab_str = sl.str.javaStringToChar(java_string)
%
%   Normally char(java_string) gets passed to opaque.char
%   This is REALLY SLOW. This bypasses a lot of the checks
%
%   Example:
%   -------------------------------------
%   char(java.lang.String('test'))
%   
%   Instead, we do:
%   
%   javaStringToChar(java.lang.String('test'))
%   

%See opaque.char


matlab_str = cell(java_string){1}; 

% cel = cell(java_string); 
% 
% matlab_str = cel{1};