function lines = getLines(str)
%x Take a string and return each line in a cell array
%
%   lines = sl.str.getLines(str)
%
%   Inputs:
%   -------
%   str :
%
%   Outputs:
%   --------
%   lines : cellstr
%       Each line is its own element in the cell array.
%
%
%   Examples:
%   ---------
%   1)
%       a = sprintf('This\nis\na\ntest');
%       b = sl.str.getLines(a);
%       disp(a)
%       disp(b)
%
%
%   See Also:
%   sl.io.readDelimitedFile

%Note, this is a relatively simple function but I think it is a bit
%cleaner, easier, and clearer to call this function than it is to call the 
%code below.


lines = regexp(str,'\r\n|\n|\r','split');
end