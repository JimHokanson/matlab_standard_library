## Filename Identification ##

This file is meant to document ways of going from a string to a file name that represents a function. I personally have not had issues with this yet but I've seen it referenced in others code. This might eventually become a function as the issue of trying to resolve a function arises. 

From checkcode/local_resolvePath

```Matlab
function fullFilename = local_resolvePath(filename)
% Locate the specified file using EXIST, WHICH, PWD, and DIR.
% The strategy is as follows:
% 1. First assume filename is relative to the CWD.  Prepend PWD.
% 2. Append .m and try again.
% 3. Try to locate filename by appending .m and using WHICH.
% 4. Try again without appending .m (this may lead to a later warning).
% 5. Now assume filename was a full path to a file.
% 6. Append .m and try again.
```