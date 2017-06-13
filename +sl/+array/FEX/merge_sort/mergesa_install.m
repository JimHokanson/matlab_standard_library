function mergesa_install
% function mergesa_install
% installation of the package merge-sorted-arrays (mergesa)

if strfind(computer(), '64')
    mex -v -O -largeArrayDims mergerowsmex.c
    mex -v -O -largeArrayDims mergemex.c
else
    mex -v -O mergerowsmex.c
    mex -v -O mergemex.c
end