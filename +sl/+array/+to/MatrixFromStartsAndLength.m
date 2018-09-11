function out = MatrixFromStartsAndLength(data_in,starts,n_samples_per_grab)
%
%
%   out = sl.array.to.MatrixFromStartStopIndices(data_in,starts,n_samples_per_grab)
%
%   Ouputs
%   -----------------------------------------------------------------------
%   out : [n_grabs x n_samples_per_grab]
%
%   Inputs
%   -----------------------------------------------------------------------
%   data_in : a vector of data (or matrix with linear indexing applied to
%       it)
%   starts  : vector of start indices to begin grabs
%   n_samples_per_grab : 
%
%   Improvements
%   -----------------------------------------------------------------------
%   1) More error checking
%   2) Allow assignment of spans to rows or columns, currently each
%   assignment spans a column
%
%   I also wrote:
%   sl.matrix.from.startAndLength
%
%   I'm not sure which approach is better ... (I think we should
%   prefer output based methods ...) - with optional shadowing

%TODO: Remove this and call sl.matrix.from.startAndLength

n_grabs = length(starts);

%TODO: Ensure n_samples_per_grab is singular

%TODO: Range check ...
%1) start within range
%2) max of start of length < length of data

out = zeros(n_grabs,n_samples_per_grab,class(data_in));

%We do a loop over whichever dimension has less iterations
if n_grabs < n_samples_per_grab
    
    %Assign each span, one at a time
    stops = starts + n_samples_per_grab - 1;
    for iGrab = 1:n_grabs
        out(iGrab,:) = data_in(starts(iGrab):stops(iGrab));
    end
else
    %Assign each element position, one at a time
    for iSample = 1:n_samples_per_grab
        out(:,iSample) = data_in(starts + (iSample - 1));
    end
end

end

function helper_examples()

width = 10; %try 100 and 1000
data_in = 1:100000;
starts = 10:width:(length(data_in)-width-10);

out = sl.array.toMatrixFromStartsAndLength(data_in,starts,width);

end