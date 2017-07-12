function output = genFromCounts(counts,values,varargin)
%genFromCounts  Provides a convenient way for generating an array based on counts
%
%   output = sl.array.genFromCounts(counts,*values)
%
%   Generates an array by replicating each value the number of times
%   specified in counts. It uses a cumaltive sum trick.
%
%   Inputs
%   ------
%   counts  : 
%       Array specifying how many times each value should appear
%               in the final output
%   values  : (default, values = counts), values to replicate for each count
%
%   Outputs
%   -------
%   output  : array of values replicated
%
%   Examples
%   --------
%   output = sl.array.genFromCounts(1:4)
%   output => 1 2 2 3 3 3 4 4 4 4
%
%   output = sl.array.genFromCounts(1:4,[3 5 6 7])
%   output => 3 5 5 6 6 6 7 7 7 7

if isempty(counts) || all(counts == 0)
    output = [];
    return
end


%See comment at end of file on why this is needed
mask = counts == 0;
any_mask = any(mask);
if any_mask
    counts(mask) = [];
end

if nargin == 1 || isempty(values)
    %NOTE: We've already truncated counts above
    values = counts;
elseif any_mask
    values(mask)  = [];
end

if isrow(counts)
    indices = false(1,sum(counts));
    indices(cumsum([1 counts(1:end-1)])) = true;
else
    indices = false(sum(counts),1);
    indices(cumsum([1; counts(1:end-1)])) = true;
end

output = values(cumsum(indices));

end

%General Algorithm
%--------------------------------------------------------------------------
%place true at start of each section
%i.e. if you want 5 of the first entry and 3 of the second
%
%index(cumsum([1 counts(1:end-1)])) = true
%   => index         - 1 0 0 0 0 1 0 0  (index is variable below)
%      indices       - 1 2 3 4 5 6 7 8
%
%Now if we do a cumsum then we get replication of the index values, n times
%   cumsum(index)
%         =>         - 1 1 1 1 1 2 2 2 - note we have 5 1s, 3 2s, etc
%
%Indexing into the original values we wish to replicate gives us the final array

%On Removing Emmpty Counts:
%--------------------------------------------------------------------------
%This is needed as our algorithm can't handle empty values
%This could be handled by assigning index values that are greater ...
%i.e. instead of index having:
%   1 0 0 0 0 1 0 0 0
%Which gets assigned to the the first two indices via cumsum
%we could instead do something like:
%   2 0 0 0 0 6 0 0 0
%
%   This would mean assign the first 5 to index 2, and then
%   after the cumsum we get the next index as 8 (2 + 6), so we would
%   assign the next few to 8
%
%   The code would be:
%
%   I   = find(counts > 0);
%   d_I = diff(I);
%   index(1) = I(1)
%   index(cumsum(counts(1:end-1))) = d_I;


