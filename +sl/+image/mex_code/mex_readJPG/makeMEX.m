function makeMEX
%
%   Dependencies:
%   -----------------------------------------------------------------------
%   1) libjpeg-turbo
%       http://sourceforge.net/projects/libjpeg-turbo/
%
%   NOTE: When installing this library tends to get placed in a default
%   location which is indicated below.
%
%   Latest versions:
%   For win64
%   http://sourceforge.net/projects/libjpeg-turbo/files/1.3.0/libjpeg-turbo-1.3.0-vc64.exe/download
%   
%   For mac
%   http://sourceforge.net/projects/libjpeg-turbo/files/1.3.0/libjpeg-turbo-1.3.0.dmg/download
%
%
%   IMPROVEMENTS
%   -----------------------------------------------------------------------
%   1) Build in support for moving file to appropriate directory. Currently
%   this needs to be done manually.


%{

Some notes on compiling:
------------------------------------------
//http://www.mathworks.com/matlabcentral/newsreader/view_thread/81585
//http://www.mathworks.com/matlabcentral/answers/35071
//
//  Windows:
//mex -I"C:\libjpeg-turbo64\include" COMPFLAGS="$COMPFLAGS /MT"  readJPG.c turbojpeg-static.lib
//  
//  Mac:
//mex -I"/opt/libjpeg-turbo/include" readJPG.c libturbojpeg.a

http://stackoverflow.com/questions/8140156/gcc-linker-cant-find-library-openni

%}

FILE_NAME = 'readJPGHelper.c';

COMP_FLAGS = '';

switch computer
    case 'PCWIN64'
        INCLUDE_PATH    = '"C:\libjpeg-turbo64\include"';
        STATIC_LIB_NAME = 'turbojpeg-static';
        STATIC_LIB_BASE_PATH = '"C:\libjpeg-turbo64\lib"';
        COMP_FLAGS      = 'COMPFLAGS="$COMPFLAGS /MT"';
    case 'MACI64'
        INCLUDE_PATH = '/opt/libjpeg-turbo/include';
        STATIC_LIB_NAME = 'turbojpeg';
        STATIC_LIB_BASE_PATH = '/opt/libjpeg-turbo/lib';
    otherwise
        error('Computer %s, not yet implemented',computer)
end
    
INCLUDE_DIRECTIVE = sprintf('-I%s',INCLUDE_PATH);
LIB_DIRECTIVE     = sprintf('-L%s',STATIC_LIB_BASE_PATH);
LINK_DIRECTIVE    = sprintf('-l%s',STATIC_LIB_NAME);

ALL_OPTIONS = {INCLUDE_DIRECTIVE,COMP_FLAGS,...
    LIB_DIRECTIVE,LINK_DIRECTIVE,FILE_NAME};

ALL_OPTIONS(cellfun('isempty',ALL_OPTIONS)) = [];

%:/
%Sadly mex(ALL_OPTIONS{:}); doesn't work because of spacing
%parsing by Matlab

cmd = ['mex ' sprintf(' %s', ALL_OPTIONS{:})];
eval(cmd)