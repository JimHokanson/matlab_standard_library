function result_class = findLocalPeak(data, search_type, varargin)
%
%
%   sci.time_series.calculators.event_calculators(data, type, varargin)
%
%   Assumptions
%   -----------
%
%   Inputs
%   ------
%   data : sci.time_series.data or double
%   search_type :
%       - 'max'
%       - 'min'
%       - 'both'
%
%
%   Optional Inputs
%   ---------------
%
%
%   -data: sci.time_series.data or double
%   -type:
%        1: maximums     2: minimums     3: both max and min
%   -threshold: the minimum peak magnitude. enter 0 for no min
%       peak size
%   -varargin: TODO (probably add threshold as a varargin)
%
%   outputs:
%   -pks: the magnitudes of the peaks which were found
%   -locs:  the index in the data of where the  pks were found
%
%   examples:
%       TODO!
%
%{
               TODO
%}

%   TODO: add option for different threshold for mins and maxs
%   when calculating both with the same method call.

in.edges_can_be_peaks = false;
in.max_threshold = [];
in.min_threshold = [];
in.threshold = [];
in.n_peaks_guess = 20;
in = sl.in.processVarargin(in,varargin);

data_class_flag = 0;
switch class(data)
    case 'sci.time_series.data'
        d = data.d;
        data_class_flag = 1;
    case 'double'
        d = data;
    otherwise
        error('unrecognized input type')
end

switch search_type
    case 'max'
        [pks, locs] = h__findLocalMaxima(d,threshold);
    case 'min'
        [pks, locs] = h__findLocalMaxima(-d,threshold);
        pks = -pks;
    case 'both'
        [maxs, max_locs] = h__findLocalMaxima(d,threshold);
        [mins, min_locs] = h__findLocalMaxima(-d,threshold);
        mins = -mins;
        
        pks = cell(1,2);
        pks{1} = maxs;
        pks{2} = mins;
        
        locs = cell(1,2);
        locs{1} = max_locs;
        locs{2} = min_locs;
    otherwise
        error('unrecognized type input')
end

if search_type == 1 || search_type == 2
    if data_class_flag
        %we can find the time locations as well as the indices
        time_locs = data.ftime.getTimesFromIndices(locs);
        result_class = sci.time_series.calculators.event_calculators.local_max_result(pks, locs, time_locs);
    else
        result_class = sci.time_series.calculators.event_calculators.local_max_result(pks, locs);
    end
else
    if data_class_flag
        temp{1} = data.ftime.getTimesFromIndices(locs{1});
        temp{2} = data.ftime.getTimesFromIndices(locs{2});
        result_class = sci.time_series.calculators.event_calculators.local_max_result(pks, locs, temp);
    else
        result_class = sci.time_series.calculators.event_calculators.local_max_result(pks, locs);
    end
end
end

function [pk, lc] =  h__findLocalMaxima(d, threshold, in)

cur_output_I = 0;
peak_indices = zeros(1,in.n_peaks_guess);


%TODO: 
%   start at 2, so, importantly, this function does not include
%   the possibility that the first datapoint is a local maximum
%   likewise, it does not include the possibility that the last
%   datapoint is a local maximum.

d_size = length(d);
for i = 2:d_size-1
    %can't use last data point
    
    %is the middle value greater than the two adjacent points?
    % yes: local max
    % no:  not a max
    %{
                        take point p
                        a) p > Left and p >=right
                            maybe... if none, then we are done
                            a.i)
                               go right
                                is point p less? -> not a local max
                                is point p equal -> keep going right (ctsly
                                         until next greater or less than)
                                is point p greater? ->it is a max!
    %}
    %boundary condition:first point
    %TODO!
    
    %   -2 -1 -2 -2 -2 0 1 2 3 4 5
    %
    %threshold = 0
    
    cur_point_value = d(i);
    if cur_point_value > threshold
        
        if (d(i) > d(i-1))
            if (d(i) < d(i+1))
                %not a local max
                
            elseif (d(i) > d(i+1))
                %this is a local max
                
                cur_output_I = cur_output_I + 1;
                if cur_output_I > length(pks)
                    temp = zeros(1,round(1.5*length(pks)));
                    temp(1:cur_output_I-1) = pks;
                    pks = temp;
                    pks = [pks zeros(1,length(pks))];
                end
                pks(cur_output_I) = d(i);
                
                locs(end+1) = i;
                
            else %(d(i) == d(i+1))
                %this might be a local max... keep going right
                count = 1;
                while((i + count) < d_size)
                    %TODO: include a give up value
                    if  d(i) < d(i+count)
                        %this is not a local max
                        break
                    elseif d(i) > d(i+count)
                        %this is a local max
                        pks(end+1) = d(i);
                        locs(end+1) = i;
                        break
                    else %d(i) == d(i+count)
                        count = count + 1;
                    end
                end
            end
        end
    end
end

%threshold calculations
if threshold ~= 0
    pk = pks(pks > threshold);
    lc = locs(pks>threshold);
else
    pk = pks;
    lc = locs;
end

end
