mlint
-----

Code in this package is meant to expose some of the functionality provided by mlintmex.

For more details see:
http://undocumentedmatlab.com/blog/parsing-mlint-code-analyzer-output

Organization
------------
This code is not the most organized as it has suffered from trying to figure out exactly what the code does as the same time that I'm writing code to wrap it.

Classes that are at this level of the package should be a bit more polished as they are meant to be called directly by the user.

Most classes in the '+mex' package call mlintmex directly and are likely to change.

Non-Hidden Functionality
------------------------
Matlab exposes some of this functionality via public functions. Some of
these are more documented than others.

checkcode: Checks Matlab code files for possible problems
mtree: Not well documented