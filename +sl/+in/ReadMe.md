# sl.in ... #

This package helps with processing of input arguments.

**Public Functions**
- [processVarargin](#processvarargin) - The standard input processor
- [splitAndProcessVarargin](#splitandprocessvarargin) - Handles inputs that are going to multiple functions

**Helper Functions**
- [NULL](#null)





## processVarargin ##

This function is meant to handle parsing of property/value pairs. It doesn't support type checking but the syntax is much shorter than Matlab's `inputParser` class. 

```matlab
function myFunction(name,varargin)
in.a = 1;
in.b = 2;
%Replaces defaults with inputs from user
in = sl.in.processVarargin(in,varargin);

fprintf('%s, a=%d, b=%d\n',name,in.a,in.b)
end

function test_code()
%Example 1
myFunction('Bill','a',3,'b',10) %Bill, a=3, b=10

%Example 2
myFunction('Jim','b',1) %Jim, a=1, b=1

%Example 3 - structs are ok too
s = struct;
s.a = 5;
s.b = 10;
myFunction('Steve',s) %Steve, a=5, b=10
end
```




## splitAndProcessVarargin ##

This function should be used if different subsets of optional inputs go into different sub-functions.

TODO: Show example

## NULL ##

This is an object which can be used to represent an unset optional input. Normally an empty array [] is sufficient to indicate an unset value, but sometimes an empty array is a valid input from the user and sl.in.NULL should be used instead.
