        
%error()
%
%error(MSGID, ERRMSG, V1, V2, ...)
%
% [component:]component:mnemonic
%   
%     that enables MATLAB to identify with a specific error. The string
%     consists of one or more COMPONENT fields followed by a single
%     MNEMONIC field. All fields are separated by colons. Here is an
%     example identifier that has 2 components and 1 mnemonic.
%   
%         'myToolbox:myFunction:fileNotFound'
%   
%     The COMPONENT and MNEMONIC fields must begin with an 
%     upper or lowercase letter which is then followed by alphanumeric  
%     or underscore characters. 