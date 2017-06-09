classdef event_calculators < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.event_calculators
    
    properties
    end
    
    methods (Static)
        result_obj = simpleThreshold(data_obj,threshold_value,look_for_positive,varargin)
        %TODO: Get this from OW code
        function result_class = findLocalMaxima(data, type, threshold, varargin)
            %   sci.time_series.calculators.event_calculators(data, type, threshold, varargin)
            %
            %   Improves upon the speed of findPeaks by removing various
            %   test cases and making some assumptions about the data:
            %   -somewhat smooth
            %   -no not a NaN
            %   -TODO: what else?
            %
            %   inputs:
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
            
            switch type
                case 1
                    %note that pks and locs get returned as row vectors
                    %(lots of columns)
                    [pks locs] = h__findLocalMaxima(d,threshold);
                case 2
                    [pks locs] = h__findLocalMaxima(-d,threshold);
                    pks = -pks;
                case 3
                    [maxs max_locs] = h__findLocalMaxima(d,threshold);
                    [mins min_locs] = h__findLocalMaxima(-d,threshold);
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

            if type == 1 || type == 2
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
        function obj =  findPeaks(data,type,varargin)
            %TODO: the output of this function is hard to deal with/not at
            %all efficient
            %   inputs:
            %   -data: sci.time_series.data class
            %   -varargin: name-value pairs for findpeaks (see matlab documentation) 
            %   -type:  
            %       1: just maximums
            %       2: just minimums
            %       3: both maximums and minimums
            %
            %   outputs:
            %   -obj: sci.time_series.calculators.event_calculators.find_peaks_result
            
            %   examples:
            %{
             findPeaks(data,3,'MinPeakHeight',threshold)
            %}
            obj = sci.time_series.calculators.event_calculators.find_peaks_result(data,type,varargin{:});   
        end
    end  
end

function [pks, locs] =  h__findLocalMaxima(d, threshold)
pks = [];
locs = [];

%   start at 2, so, importantly, this function does not include
%   the possibility that the first datapoint is a local maximum
%   likewise, it does not include the possibility that the last
%   datapoint is a local maximum.
for i = 2:length(d)
    if i == length(d)
        break; %can't use last data point
    end
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
    
    if (d(i)>d(i-1)) && (d(i)>d(i+1))
        %this is a local max
        pks(end+1,1) = d(i);
        locs(end+1,1) = i;
        
    elseif (d(i)>d(i-1)) && (d(i) == d(i+1))
        %this might be a local max... keep going right
        count = 1;
        while(1)
            if d(i) > d(i+count)
                %this is a local max
                pks(end+1,1) = d(i);
                locs(end+1,1) = i;
                break;
            elseif d(i) < d(i+count)
                %this is not a local max
                break;
            end
            
            % don't want to go outside of the data we have
            % this is a highly unlikely case
            if (i+count) == length(d)
                break;
            end
            count = count + 1;
        end
    end
end

%threshold calculations
if threshold ~= 0
    pks = pks(pks > threshold);
    locs = locs(pks>threshold);
end
end
    
