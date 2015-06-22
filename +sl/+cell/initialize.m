function output = initialize(size_array,value,varargin)
%x Initialize a cell array to a particular value
%
%   Calling Forms:
%   --------------
%   1) 
%   output = sl.cell.initialize(size_array,value)
%
%
%   Summmary:
%   ---------
%   This is a relatively simple function that is just meant to take some of
%   the verbosity out of some code.
%
%   Examples:
%   ---------
%   output = sl.cell.initialize([2,3],5)
%   output =>
%     [5]    [5]    [5]
%     [5]    [5]    [5]   
%
%   See Also:
%   ---------
%   cell

if length(size_array) == 1
    size_array = [size_array 1];
end

output = cell(size_array);
output(:) = {value};

end