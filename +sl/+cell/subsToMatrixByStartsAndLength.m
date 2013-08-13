function out = subsToMatrixByStartsAndLength(data_in,starts,n_samples_per_grab)
%
%
%   out = sl.cell.subsToMatrixByStartsAndLength(starts,n_samples_per_grab)
%
%
%   TODO: Add documentation ...
%
%   See Also:
%   sl.array.toMatrixFromStartStopIndices
%   sl.cell.catSubElements

n_grabs = length(data_in);

out = zeros(n_grabs,n_samples_per_grab,class(data_in{1}));

if numel(starts) == 1
    start_value = starts;
    stop_value  = start_value + n_samples_per_grab - 1;
    for iGrab = 1:n_grabs
        out(iGrab,:) = data_in{iGrab}(starts:stop_value);
    end
else
    %Assign each span, one at a time
    stops = starts + n_samples_per_grab - 1;
    for iGrab = 1:n_grabs
        out(iGrab,:) = data_in{iGrab}(starts(iGrab):stops(iGrab));
    end
end


end