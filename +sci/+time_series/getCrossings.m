function indices = getCrossings(data,level,varargin)
%
%
%   indices = sci.time_series.getCrossings(data,level,varargin)

if level >= 0
    in.edge = 'rising';
else
    in.edge = 'falling';
end

in.use_closest = false; %NYI: Let's say we are looking for a rising
%cross above 10, and our values at two consecutive indices are 5 and 40.
%Normally we will use 40, as it follows the crossing, but 5 is obvioulsy
%closer to 10, so we might want to return the index that corresponds to 5
%instead
in.fs = []; %NYI
in.time_too_close    = []; %This gets applied forward in time only. Requires fs
in.samples_too_close = [];

in = sl.in.processVarargin(in,varargin);

if size(data,1) == 1
    data = data';
end

switch in.edge
    case 'rising'
        indices = find(data >= level & [false; data(1:(end-1))] < level);
    case 'falling'
        indices = find(data <= level & [false; data(1:(end-1))] > level);
    otherwise
        error('Unrecognized edge option')
end

if isempty(indices)
    return
end

if ~isempty(in.time_too_close)
    if isempty(in.fs)
        error('The fs input must be specified in order to limit in time')
    end
    samples_too_close = in.time_too_close*in.fs;
elseif ~isempty(in.samples_too_close)
    samples_too_close = in.samples_too_close;
else
    samples_too_close = [];
end

if ~isempty(samples_too_close)
    last_good_index = indices(1);
    keep_mask = true(1,length(indices));
    for iIndex = 2:length(indices)
        if indices(iIndex) - last_good_index < samples_too_close
            keep_mask(iIndex) = false;
        else
            last_good_index = indices(iIndex);
        end
    end
    indices(~keep_mask) = [];
end