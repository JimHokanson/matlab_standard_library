function [starts,stops] = getSplitIndices(start,stop,varargin)
%
%   [starts,stops] = sl.array.split.getSplitIndices(start,stop,'n_parts,n_parts)
%
%   NOT YET IMPLEMENTED
%   [starts,stops] = sl.array.split.getSplitIndices(start,stop,'split_percentages,split_percentages)
%
%   Examples
%   --------
%   [starts,stops] = sl.array.split.getSplitIndices(2,20,'n_parts',3)
%
%   

in.n_parts = [];
in.split_percentages = [];
in = sl.in.processVarargin(in,varargin);

if ~isempty(in.n_parts)
    [starts,stops] = h__nSplit(start,stop,in.n_parts);
elseif ~isempty(in.pct_splits)
    error('Not yet implemented')
else
   error('Function requires specification of either "n_splits" or "pct_splits'); 
end


end

function [starts,stops] = h__nSplit(start,stop,n_parts)

%TODO: Error checking
%n_parts > 0 and integer

if n_parts == 1
    starts = start;
    stops = stop;
    return;
end

n_samples = stop - start + 1;

if n_parts > n_samples
    error('n_parts (%d) is more than n_samples (%d)',n_parts,n_samples)
end

n_splits = n_parts - 1;

n_samples_per_part = n_samples/n_parts;

temp_start = start + (0:n_splits)*n_samples_per_part;

%I think that round, floor, or ceil are all fine. You'll get some slight
%differences between them. We might want to expose this option to the user
%...
starts = round(temp_start);
stops = [starts(2:end)-1 stop];

end

% tic;
% for i = 1:1000
% 
% toc