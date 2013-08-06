function out = toMatrixFromStartsAndLength(data_in,starts,n_samples_per_grab)
%
%
%   out = sl.array.toMatrixFromStartStopIndices(data_in,starts,n_samples_per_grab)
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

n_grabs = length(starts);

%TODO: Ensure n_samples_per_grab is singular

%TODO: Range check ...
%1) start within range
%2) max of start of length < length of data

out = zeros(n_grabs,n_samples_per_grab,class(data_in));

%We do a loop over whichever dimension has less iterations
if n_grabs < n_samples_per_grab
    stops = starts + n_samples_per_grab - 1;
    for iGrab = 1:n_grabs
        out(iGrab,:) = data_in(starts(iGrab):stops(iGrab));
    end
else
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