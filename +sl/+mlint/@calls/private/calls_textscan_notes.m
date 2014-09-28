    

%#
%0 - top level
%1 - normal calls within functions
%2 - calls within nested fubctions


%A - anonymous function
%M - main method in file 
%E - end of function
%  - I think this doesn't exist for anonymous functions
%N - nested functions
%S - subfunction, functions in classdef including constructors show up as
%   this, not as M
%U - called function - functions outside their scope, undefined



% M0 1 10 test_file_001
% E0 7 11 test_file_001
% U1 5 11 unique
% U1 5 18 rand
% U1 7 6 false


%   EXAMPLE DATA
%   ===================================================================
%     U0 27 31 zeros
%     U0 36 31 cell
%     S0 76 24 get.parent
%     E0 98 11 get.parent
%     U1 88 19 dbstack
%     U1 89 17 isempty
%     U1 90 21 any
%     U1 90 25 strcmp
%     U1 91 27 subsref
%     U1 91 40 substruct
%     S0 104 24 HDS
%     E0 207 11 HDS
%     U1 107 39 clock
%     U1 108 39 uint32
%     U1 111 39 zeros
%     U1 111 45 length
%     U1 126 17 strcmp
%     U1 126 24 class
%     U1 128 27 regexp