function result = findLocalPeak(data, search_type, varargin)
%x Finds local peak based on criteria
%
%   result = sci.time_series.calculators.event_calculators.findLocalPeak
%                   (data, search_type, varargin)
%
%   Whereas min() or max() return the global minima and maxima, this
%   function returns peaks that are greater (or less than) its neighbors
%   (depending upon if we are looking for maxima or minima respectively).
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
%   edges_can_be_peaks : default false
%       If true then the first and last samples may be peaks as well.
%       Unlike other samples the result only depends on one neighboring
%       sample, rather than two.
%   max_threshold : default []
%       Used only when search_type = 'max' or 'both'. Peaks are only peaks
%       if greater than this value.
%   min_threshold : default []
%       Used only whjen search_type = 'min' or 'both'. Peaks are only
%       peaks if less than this value.
%   threshold : default []
%       Can be used rather than 'max_threshold' or 'min_threshold' with
%       the sign interpretation depending upon 'search_type'
%   n_peaks_guess : (default 20)
%       Used to optimize memory allocation.
%
%   Outputs
%   -------
%   result : sci.time_series.calculators.event_calculators.find_local_peaks_result
%
%   Improvements
%   ------------
%   1) add option for different threshold for mins and maxs
%   when calculating both with the same method call.
%   2) Allow filtering peaks based on width. In other words a peak
%   is a peak if it is greater than X number of samples to the right and
%   left.
%   3) Rename to be plural!!!!

in.min_distance = [];
in.edges_can_be_peaks = false;
in.max_threshold = [];
in.min_threshold = [];
in.threshold = [];
in.n_peaks_guess = 20;
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
        d = data;
    otherwise
        error('unrecognized input type')
end

%---------------------------------------

%Input handling
%--------------------
if in.n_peaks_guess < 1
    in.n_peaks_guess = 10;
end

%---------------------------------------

switch search_type
    case 'max'
        if isempty(in.threshold) && isempty(in.max_threshold)
            threshold = NaN;
        elseif isempty(in.threshold)
            threshold = in.max_threshold;
        else
            threshold = in.threshold;
        end
        peak_indices = h__findLocalMaxima(d,threshold,in);
        is_max = true(1,length(peak_indices));
    case 'min'
        if isempty(in.threshold) && isempty(in.min_threshold)
            threshold = NaN;
        elseif isempty(in.threshold)
            threshold = in.min_threshold;
        else
            threshold = in.threshold;
        end
        peak_indices = h__findLocalMaxima(-d,threshold,in);
        is_max = false(1,length(peak_indices));
    case 'both'
        
        error('Not yet implemented')
        
        if isempty(in.threshold) && isempty(in.max_threshold)
            mex_threshold = NaN;
        elseif isempty(in.threshold)
            mex_threshold = in.max_threshold;
        else
            mex_threshold = in.threshold;
        end
        
        if isempty(in.threshold) && isempty(in.min_threshold)
            min_threshold = NaN;
        elseif isempty(in.threshold)
            min_threshold = in.min_threshold;
        else
            min_threshold = in.threshold;
        end
        
        
        
%         [maxs, max_locs] = h__findLocalMaxima(d,threshold);
%         [mins, min_locs] = h__findLocalMaxima(-d,threshold);
%         mins = -mins;
%         
%         pks = cell(1,2);
%         pks{1} = maxs;
%         pks{2} = mins;
%         
%         locs = cell(1,2);
%         locs{1} = max_locs;
%         locs{2} = min_locs;

%Would need to merge min and max
    otherwise
        error('unrecognized type input')
end

if data_class_flag
    times = data.ftime.getTimesFromIndices(peak_indices);
else
    times = [];
end

values = d(peak_indices);


% if search_type == 1 || search_type == 2
%     if data_class_flag
%         %we can find the time locations as well as the indices
%         time_locs = data.ftime.getTimesFromIndices(locs);
%         result = sci.time_series.calculators.event_calculators.local_max_result(pks, locs, time_locs);
%     else
%         result = sci.time_series.calculators.event_calculators.local_max_result(pks, locs);
%     end
% else
%     if data_class_flag
%         temp{1} = data.ftime.getTimesFromIndices(locs{1});
%         temp{2} = data.ftime.getTimesFromIndices(locs{2});
%         result = sci.time_series.calculators.event_calculators.local_max_result(pks, locs, temp);
%     else
%         result = sci.time_series.calculators.event_calculators.local_max_result(pks, locs);
%     end
% end

result = sci.time_series.calculators.event_calculators.find_local_peaks_result(...
                  peak_indices,times,values,is_max);


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

