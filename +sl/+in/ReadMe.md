# sl.in ... #

This package helps with processing of input arguments.

Public Functions
- [processVarargin](#processvarargin) - The standard input processor
- [splitAndProcessVarargin](#splitandprocessvarargin)

Helper Functions
- [NULL](#null)

## processVarargin ##

This function is meant to handle parsing of property/value pairs. It doesn't support type checking but the syntax is much shorter than Matlab's `inputParser` class. 

```matlab
function myFunction(name,varargin)

in.a = 1;
in.b = 2;
in = sl.in.processVarargin(in,varargin)
end

disp(sprintf('%s,a:%d,b:%d',name,in.a,in.b))
end

function test_code()

myFunction('Bill','a',3)

myFunction('Jim','b',1)

s = struct;
s.a = 5;
s.b = 10;

myFunction('Steve',s)


end

```

TODO: Show example

## splitAndProcessVarargin ##

This function should be used if different subsets of optional inputs go into different sub-functions.

TODO: Show example

## NULL ##

This is an object which can be used to represent an unset optional input. Normally an empty array [] is sufficient to indicate an unset value, but sometimes an empty array is a valid input from the user and sl.in.NULL should be used instead.
