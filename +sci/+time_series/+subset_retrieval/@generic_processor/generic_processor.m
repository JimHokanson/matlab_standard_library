classdef generic_processor < sci.time_series.subset_retrieval.processor
    %
    %   Class
    %   sci.time_series.subset_retrieval.generic_processor
    %
    %   Supported Calling Forms - TODO: Map to subset retrieval calls
    %   -----------------------
    %   1) start_samples, stop_samples          fromStartAndStopSamples
    %   2) start_samples, sample_duration       fromStartSampleAndSampleDuration
    %   3) start_samples, time_duration         fromStartSampleAndTimeDuration
    %   4) start_times, stop_times              fromStartAndStopTimes
    %   5) start_times, sample_duration
    %   6) start_times, time_duration
    %   7) subset_pct                           fromPercentSubset
    %   8) n_parts                              intoNParts
    %   9) split_percentages                    splitAtPercentages
    %
    %   Improvements
    %   ------------
    %   1) Support broadcasting the samples or times to each object
    %
    %
    %   See Also
    %   --------
    %   sci.time_series.subset_retrieval.processor
    %
    %   Ignore
    %   ------
    %#ok<*PROPLC>  - using variable the same as object property name
    
    properties
        start_samples
        stop_samples
        
        start_times
        stop_times
        
        time_duration
        sample_duration
        
        subset_pct %[start stop] values should be between 0 and 1
        
      	un = true;
        
        %This doesn't look like it is used ...
        align_time_to_start = false;
        
        relative_time = false
    end
    
    methods
        function set.subset_pct(obj,value)
           if length(value) ~= 2
               error('subset_pct must have 2 values')
           end
           obj.subset_pct = value;
        end
    end
    
    methods
        function [start_samples,stop_samples] = getStartAndStopSamples(obj,data_objects)
            n_objects = length(data_objects);
            
            stop_samples = [];
            
            %TODO: If we specifiy subset_pct this doesn't work
            %with start and stop samples ...
            
            %Start samples
            %-------------------------------------------
            if ~isempty(obj.start_times)
                start_times = cell(1,n_objects);
                start_times(:) = {obj.start_times};
                start_samples = obj.timesToSamples(data_objects,start_times,...
                    'relative_time',obj.relative_time);
            elseif ~isempty(obj.start_samples)
                start_samples = cell(1,n_objects);
                start_samples(:) = {obj.start_samples};
            elseif ~isempty(obj.subset_pct)
                start_samples = cell(1,n_objects);
                stop_samples = cell(1,n_objects);
                pct_local = obj.subset_pct;
                for iObject = 1:n_objects
                    cur_obj = data_objects(iObject);
                    cur_n_samples = cur_obj.n_samples;
                    %JAH 2/2020 - Bug Fix
                    %0 should map to sample 1
                    start_samples{iObject} = ceil(pct_local(1)*cur_n_samples)+1;
                    stop_samples{iObject} = ceil(pct_local(2)*cur_n_samples);
                end
            else
                start_samples = cell(1,n_objects);
                start_samples(:) = {1};
            end
            
            %Stop Samples
            %-------------------------------------------
            if isempty(stop_samples)
                if ~isempty(obj.stop_samples)
                    stop_samples = cell(1,n_objects);
                    stop_samples(:) = {obj.stop_samples};
                elseif ~isempty(obj.stop_times)
                    stop_times = cell(1,n_objects);
                    stop_times(:) = {obj.stop_times};
                    stop_samples = obj.timesToSamples(data_objects,stop_times,...
                        'relative_time',obj.relative_time);
                elseif ~isempty(obj.time_duration)
                    stop_samples = cellfun(@(x,y) x + y.ftime.durationToNSamples(obj.time_duration),...
                        start_samples,num2cell(data_objects),'un',0);
                elseif ~isempty(obj.sample_duration)
                    stop_samples = cellfun(@(x) x + obj.sample_duration,start_samples,'un',0);
                else
                    stop_samples = arrayfun(@(x) x.n_samples,data_objects,'un',0);
                end
            end
            
            [start_samples,stop_samples] = obj.processSplits(start_samples,stop_samples);
            
        end
        
    end
    
end
