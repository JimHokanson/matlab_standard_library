function result = findLocalPeaks(data, search_type, varargin)
%x Finds local peak based on criteria
%
%   result = sci.time_series.calculators.event_calculators.findLocalPeaks
%                   (data, search_type, varargin)
%
%   Whereas min() or max() return the global minima and maxima, this
%   function returns peaks that are greater (or less than) its neighbors
%   (depending upon if we are looking for maxima or minima respectively).
%
%   Outputs
%   -------
%   result : sci.time_series.calculators.event_calculators.find_local_peaks_result
%
%   Inputs
%   ------
%   data : sci.time_series.data or double
%   search_type :
%       - 'max' - peaks must be highest
%       - 'min' - peaks must be lowest
%       - 'both' - peaks must be highest or lowest
%
%   Optional Inputs
%   ---------------
%   flat_selection : default 'center'
%       At a flat peak (equal values) choose:
%       - 'center'
%       - 'first'
%       - 'last'
%       - 'all'
%   max_n: 
%       The max # of peaks to return.
%   min_prominence
%   min_sample_distance
%   min_time_distance
%
%   max_threshold : default []
%       Used only when search_type = 'max' or 'both'. Peaks are only peaks
%       if greater than this value.
%   min_threshold : default []
%       Used only when search_type = 'min' or 'both'. Peaks are only
%       peaks if less than this value.
%   threshold : default []
%       Can be used rather than 'max_threshold' or 'min_threshold' with
%       the sign interpretation depending upon 'search_type'
%
%   Examples
%   --------
%   first_difference = diff(raw_data)
%   result = c.eventz.findLocalPeaks(first_difference,

%{
data = 1:1e6;
search_type = 'max'
varargin = {'test',1,[],[],3,4};
result = sci.time_series.calculators.event_calculators.findLocalPeaks(...
    data,search_type,varargin{:})
%}

%- min_prominence : MinProminence
%- flat_selection : FlatSelection
%   + 'center'
%   + 'first'
%   + 'last'
%   + 'all'
%- min_distance : MinSeparation
%- max_n : MaxNumExtrema
%-

in.flat_selection = '';
in.max_n = [];
in.min_prominence = [];
in.min_sample_distance = [];
in.min_time_distance = [];
in.min_threshold = [];
in.max_threshold = [];
in.threshold = [];
% in.edges_can_be_peaks = false;
% in.n_peaks_guess = 20;
in = sl.in.processVarargin(in,varargin);

data_class_flag = 0;
switch class(data)
    case 'sci.time_series.data'
        if data.n_channels > 1
            error('Only a single channel is supported')
        end
        d = data.d;
        data_class_flag = 1;
    case 'double'
        %TODO: error check ...
        d = data;
    otherwise
        error('unrecognized input type')
end

%---------------------------------------
if ~exist('islocalmin') %#ok<EXIST>
    error('Code has been written to use islocamin function which requires 2017a or newer')
end

%---------------------------------------
options = cell(1,8);
keep_mask = false(1,8);
if ~isempty(in.flat_selection)
    options{1} = 'FlatSelection';
    options{2} = in.flat_selection;
    keep_mask(1:2) = true;
end
if ~isempty(in.min_prominence)
    options{3} = 'MinProminence';
    options{4} = in.min_prominence;
    keep_mask(3:4) = true;
end
if ~isempty(in.max_n)
    options{5} = 'MaxNumExtrema';
    options{6} = in.max_n;
    keep_mask(5:6) = true;
end
if ~isempty(in.min_time_distance) || ~isempty(in.min_sample_distance)
    if ~isempty(in.min_sample_distance)
        sample_distance = in.min_sample_distance;
    else
        if data_class_flag
            sample_distance = ceil(in.min_time_distance*data.time.fs);
        else
            error('Time specification not supported for non time-series input')
        end
    end
 	options{7} = 'MinSeparation';
    options{8} = sample_distance;
    keep_mask(7:8) = true;
end

options2 = options(keep_mask);

if any(strcmp(search_type,{'max','both'}))
    if isempty(in.threshold) && isempty(in.max_threshold)
        threshold = NaN;
    elseif isempty(in.threshold)
        threshold = in.max_threshold;
    else
        threshold = in.threshold;
    end
    %This can be really slow ...
    mask = islocalmax(d,options2{:});
    peak_I_max = find(mask);
    if ~isnan(threshold)
        peak_I_max(d(peak_I_max) < threshold) = [];
    end
end

if any(strcmp(search_type,{'min','both'}))
    if isempty(in.threshold) && isempty(in.min_threshold)
        threshold = NaN;
    elseif isempty(in.threshold)
        threshold = in.min_threshold;
    else
        threshold = in.threshold;
    end
    %     peak_indices = h__findLocalMaxima(-d,threshold,in);
    mask = islocalmin(d,options2{:});
    peak_I_min = find(mask);
    if ~isnan(threshold)
        peak_I_min(d(peak_I_min) >= threshold) = [];
    end
end

switch search_type
    case 'max'
        peak_I = peak_I_max;
        is_max = true(1,length(peak_I));
    case 'min'
        peak_I = peak_I_min;
        is_max = false(1,length(peak_I));
    case 'both'
        try
            [peak_I,I_sort] = sort([peak_I_max; peak_I_min]);
        catch
            [peak_I,I_sort] = sort([peak_I_max peak_I_min]);
        end
        is_max = I_sort <= length(peak_I_max);
end

if data_class_flag
    times = data.ftime.getTimesFromIndices(peak_I);
else
    times = [];
end

values = d(peak_I);

result = sci.time_series.calculators.event_calculators.find_local_peaks_result(...
    data,peak_I,times,values,is_max);


end

function peak_indices = h__findLocalMaxima(d, threshold, in)

% in.edges_can_be_peaks = false;
% in.max_threshold = [];
% in.min_threshold = [];
% in.threshold = [];
% in.n_peaks_guess = 20;
% in = sl.in.processVarargin(in,varargin);



cur_output_I = 0;
peak_indices = zeros(1,in.n_peaks_guess);

cur_input_I = 2;
current_value = d(1);
next_value = d(2);
if in.edges_can_be_peaks
    if d(1) > d(2)
        peak_indices(1) = 1;
        cur_output_I = 1;
    elseif d(1) == d(2)
        [next_value,peak_indices,cur_output_I,cur_input_I] = ...
            h__seekRight(d,current_value,1,peak_indices,cur_output_I);
    end
end

stop_point = length(d)-1;
while cur_input_I < stop_point
    
    last_value = current_value;
    current_value = next_value;
    next_value = d(cur_input_I+1);
    
    if current_value > last_value
        if current_value < next_value
            %Simple case, not greater than the next value
            %----------------------------------------------
            %- next value is possible
            cur_input_I = cur_input_I + 1;
        elseif current_value > next_value
            %Simple case, greater than left and right
            %----------------------------------------
            cur_output_I = cur_output_I + 1;
            if cur_output_I > length(peak_indices)
                %Doubling of size
                peak_indices = [peak_indices zeros(1,cur_output_I)]; %#ok<AGROW>
            end
            peak_indices(cur_output_I) = cur_input_I;
            cur_input_I = cur_input_I + 2;
        else
            %Complex, greater than previous, same as next
            %---------------------------------------------
            % - precede to the right to determine if max or not
            % - least likely outcome, thus last
            [next_value,peak_indices,cur_output_I,cur_input_I] = ...
                h__seekRight(d,current_value,cur_input_I,peak_indices,cur_output_I);
            
        end
    else
        %not greater than the previous value, move to the next value
        cur_input_I = cur_input_I + 1;
    end
end

%Edge handling
%-----------------------------------------------
if in.edges_can_be_peaks
    %End point
    %---------
    if d(end) > d(end-1)
        cur_output_I = cur_output_I + 1;
        if cur_output_I > length(peak_indices)
            peak_indices(end+1) = length(d);
        else
            peak_indices(cur_output_I) = length(d);
        end
    end
end

%Trimming
%--------------------------------------
peak_indices(cur_output_I+1:end) = [];
if ~isnan(threshold)
    peak_indices(d(peak_indices) < threshold) = [];
end


end

function [next_value,peak_indices,cur_output_I,next_input_I] = ...
    h__seekRight(d,current_value,cur_input_I,peak_indices,cur_output_I)

%
%   We keep going to the right until we run out data or until a point
%   is not the same as the current value. If the value is larger, then our
%   current value is not a peak. If the value is smaller, than our current
%   value is a peak. This is illustrated in the code below.
%
%   TODO: Document inputs and outputs


%Find the next point which is not equal to the current value
%---------------------------------------------------------------
next_test_index = cur_input_I + 2;
while (next_test_index <= length(d) && current_value == d(next_test_index))
    next_test_index = next_test_index + 1;
end

%Process stop reason
%----------------------------
is_local_max = true;
if next_test_index > length(d)
    %Ran out of data, so our point is a local max
    %--------------------------------------------
    next_value = NaN;
    next_input_I = next_test_index;
elseif current_value > d(next_test_index)
    %Eventually our point went down, so we have a local max
    %
    %          o . . . . .
    %  . . . .             x . . . .
    %   o - point we are curious about
    %   x - point we stopped at, so 'o' is a local peak
    
    next_value = d(next_test_index);
    %current_value = d(stop_index-1); %which is the current value
    next_input_I = next_test_index + 1;
else
    %not a local max, since we decreased relative to the next peak
    %
    %                      x . . . .
    %          o . . . . .
    %  . . . .
    %   o - point we are curious about
    %   x - point we stopped at, so 'o' is not a local peak
    
    is_local_max = false;
    next_value = d(next_test_index);
    next_input_I = next_test_index;
end

if is_local_max
    cur_output_I = cur_output_I + 1;
    if cur_output_I > length(peak_indices)
        %Doubling of size
        peak_indices = [peak_indices zeros(1,cur_output_I)];
    end
    peak_indices(cur_output_I) = cur_input_I;
end


end

function h__tests()
profile on
tic
N = 1e8;
fh = @sci.time_series.calculators.event_calculators.findLocalPeak;
d = zeros(1,N);
d(N) = 1;

%Edge testing
%---------------------------------------------------------
%Ignoring edge peaks
r = fh(d,'max');
assert(isempty(r),'Expected no results')

%Not ignoring edge peaks
r = fh(d,'max','edges_can_be_peaks',true);
assert(isequal(r,N),'Last point should be a peak')

%First edge
d(1) = 1;
r = fh(d,'max','edges_can_be_peaks',true);
assert(isequal(r,[1 N]),'first edge with seeking error');

%Ege Peak requires right seeking
d(2:5) = 1;
r = fh(d,'max','edges_can_be_peaks',true);
assert(isequal(r,[1 N]),'first edge with seeking error');

%Main functionality testing
%---------------------------------------------------------
d(:) = 0;
d(2:5:N) = 1;
r = fh(d,'max');
assert(isequal(r,2:5:N),'mismatch in basic peek finding');

%bumping to the right, peaks should still be the first points
d(3:5:N) = 1;
r = fh(d,'max');
assert(isequal(r,2:5:N),'mismatch in basic peek finding');

%Threshold testing
%TODO


%test run at the end
d(:) = 0;
d(N-10:N) = 1;
r = fh(d,'max');
assert(isequal(r,N-10),'peak at end matches')
toc
profile off
profile viewer

end

