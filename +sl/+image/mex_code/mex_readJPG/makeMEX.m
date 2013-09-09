function makeMEX
%
%
%   Dependencies:
%   -----------------------------------------------------------------------
%   libjpeg-turbo
%   http://sourceforge.net/projects/libjpeg-turbo/
%   
%   Latest versions:
%   For win64
%   http://sourceforge.net/projects/libjpeg-turbo/files/1.3.0/libjpeg-turbo-1.3.0-vc64.exe/download
%   
%   For mac
%   ?????
%   http://sourceforge.net/projects/libjpeg-turbo/files/1.3.0/libjpeg-turbo-1.3.0.tar.gz/download

FILE_NAME = 'readJPGHelper.c';

COMP_FLAGS = '';

%TODO: We need an architecture switch as well
switch computer
    case 'PCWIN64'
        INCLUDE_PATH    = '"C:\libjpeg-turbo64\include"';
        STATIC_LIB_NAME = 'turbojpeg-static';
        STATIC_LIB_BASE_PATH = '"C:\libjpeg-turbo64\lib"';
        COMP_FLAGS = 'COMPFLAGS="$COMPFLAGS /MT"';
    case 'MACI64'
        INCLUDE_PATH = '/opt/libjpeg-turbo/include';
        STATIC_LIB_NAME = 'libturbojpeg.a';
        error('Finish this ...')
        %STATIC_LIB_BASE_PATH = ''???
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
%Sadly mex(ALL_OPTIONS{:}); doesn't work

cmd = ['mex ' sprintf(' %s', ALL_OPTIONS{:})];
eval(cmd)