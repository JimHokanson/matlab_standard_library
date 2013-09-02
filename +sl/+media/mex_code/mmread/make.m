%make
%
%
%   This is currently not finished. The dependencies are unclear.
%
%   avibin.h

% The new version of mmread is supposed to work just like the old one. When
% I build FFGrab.mexw32, I include a direction to Windows for it to look
% for avbin.dll in the same directory as where FFGrab.mexw32 is located. I
% had confirmed that this in fact did work a while ago but haven't tested
% it recently. Once I have access again to a Windows system with Matlab,
% I'll test it. What version of Windows are you using?
% 
% As a work around, edit mmread.m and change the lines "if ~ispc" to "if
% true" and "if ~strmatch(computer,'PCWIN')" to "if true". Under Linux and
% Mac, there isn't a way to get a library (avbin) to load from the same
% directory as the library that loaded it (FFGrab.mex*), so I have mmread
% change the current directory when it is called and then change it back.