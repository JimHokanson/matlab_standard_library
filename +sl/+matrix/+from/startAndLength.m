function output = startAndLength(data,start_Is,n_samples,varargin)
%X Create a matrix from an array by specifying start points
%
%   output = sl.matrix.from.startAndLength(data,start_Is,n_samples)
%
%   Inputs
%   ------
%   start_Is : 
%       Start indices of where to grab.
%   n_samples :
%       # of samples to grab. This must be a scalar
%   
%   Optional Inputs
%   ---------------
%   by_row: (default true)
%       - true, samples from each start occupies a single row
%       - false, samples from each start occupies a single column
%
%   Example
%   -------
%   wtf = sl.matrix.from.startAndLength(d1,I-5,15)
%
%   Improvements
%   ------------
%   1) We could allow a variable # of samples per grab, with some default
%   padding.

in.by_row = true;
in = sl.in.processVarargin(in,varargin);

%I think for now a loop might be the fastest ....
% - as long as we aren't using the profiler

n_starts = length(start_Is);
n_add = n_samples - 1;

if in.by_row
    output = zeros(n_starts,n_samples,'like',data);
    for iStart = 1:n_starts
        cur_start = start_Is(iStart);
        output(iStart,:) = data(cur_start:cur_start+n_add);
    end
else
    output = zeros(n_samples,n_starts,'like',data);
    for iStart = 1:n_starts
        cur_start = start_Is(iStart);
        output(:,iStart) = data(cur_start:cur_start+n_add);
    end
end



end