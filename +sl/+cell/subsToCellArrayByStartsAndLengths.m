function out = subsToCellArrayByStartsAndLengths(data_in,starts,n_samples_each_grab)
%
%
%   out = sl.cell.subsToMatrixByStartsAndLengths(data_in,starts,n_samples_each_grab)
%
%
%   TODO: Add documentation ...
%
%   See Also:
%   sl.array.toMatrixFromStartStopIndices
%   sl.cell.catSubElements

n_grabs = length(data_in);

out = cell(1,n_grabs);

if numel(starts) == 1 && length(n_samples_each_grab) > 1
   starts = repmat(starts,size(n_samples_each_grab)); 
end

%Assign each span, one at a time
stops = starts + n_samples_each_grab - 1;

%identifier: 'MATLAB:mixedClasses'
%:/ Would be nice to try/catch this ...
%Not sure what to do

for iGrab = 1:n_grabs
    out{iGrab} = data_in{iGrab}(starts(iGrab):stops(iGrab));
end



end