%{

    compile_findThresholdCrossings

%}

%This was written to support compiling with openmp
%

%To compile without just call:
%   mex mex_findThresholdCrossings.c

%TODO: 
%1) Clear old from memory
%2) move after compiling

%Jim GitHub mex maker code
c = mex.compilers.gcc('mex_findThresholdCrossings.c','verbose',true);
c.addCompileFlags({'-mavx','-mabm','-mbmi'});

%from big_plot.compile - is this for openmp?
if strcmp(c.gcc_type,'mingw64')
    c.addStaticLibs({'pthread'})
end

c.addLib('openmp');
c.build();