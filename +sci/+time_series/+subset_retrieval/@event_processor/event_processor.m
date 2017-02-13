classdef event_processor < sci.time_series.subset_retrieval.processor
    %
    %   Class:
    %   sci.time_series.subset_retrieval.event_processor
    %
    %   The main access point is meant to be in:
    %       sci.time_series.subset_retrieval
    %
    %   
    %
    %   See Also
    %   --------
    %   sci.time_series.subset_retrieval
    
    %TODO: Can we pass an object into processVarargin???
    
    properties
        d0 = '---------  Must have values -----------'
        start_name
        start_indices = 1;
        un = true;
        align_time_to_start = false;
        
        %These are optional
        stop_name
        stop_indices = 1;
        time_duration
        sample_duration
        time_offsets
        sample_offsets
    end
    
    methods
        function [start_samples,stop_samples] = getStartAndStopSamples(obj,data_objects)
            
            n_objects = length(data_objects);
            
            stop_times = cell(1,n_objects);
            
            %Note, that we have 1 event for each
            start_events = data_objects.getEvent(obj.start_name);
            
            
            
            
            
            %1) Retrieval of times ...
            %--------------------------------------------------------------
            start_times = h__process_indices(obj,obj.start_indices,n_objects,start_events);
            
            stop_time_defined = true;
            if ~isempty(obj.time_duration)
                stop_times = cellfun(@(x) x + obj.time_duration,start_times,'un',0);
            elseif ~isempty(obj.time_offsets)
                stop_times = cellfun(@(x) x + obj.time_offsets(2),start_times','un',0);
                start_times = cellfun(@(x) x + obj.time_offsets(1),start_times','un',0);
            else
                if isempty(obj.sample_duration) && isempty(obj.sample_offsets)
                    stop_events = data_objects.getEvent(obj.stop_name);
                    stop_times = h__process_indices(obj,obj.stop_indices,n_objects,stop_events);
                else
                    stop_time_defined = false;
                end
            end
            
            %Change times to samples
            %-----------------------
            start_samples = obj.timesToSamples(data_objects,start_times);
            if stop_time_defined
                stop_samples  = obj.timesToSamples(data_objects,stop_times);
            end

            %Implement sample based window
            %-----------------------------
            if ~isempty(obj.sample_offsets)
                stop_samples  = cellfun(@(x) x + obj.sample_offsets(2),start_samples,'un',0);
                start_samples = cellfun(@(x) x + obj.sample_offsets(1),start_samples,'un',0);
            elseif ~isempty(obj.sample_duration)
                stop_samples  = cellfun(@(x) x + obj.sample_duration,start_samples,'un',0);
            end
            
            [start_samples,stop_samples] = obj.processSplits(start_samples,stop_samples);
            
        end
    end
    
end

function times = h__process_indices(obj,indices,n_objects,events)

    if ischar(indices)
        times = cell(1,n_objects);
        for iEvent = 1:n_objects
            times{iEvent} = events(iEvent).times;
        end
    elseif isa(obj.start_indices,'function_handle')
        times = arrayfun(indices,events,'un',0);
    else
        times = cell(1,n_objects);
        I = indices;
        for iEvent = 1:n_objects
            times{iEvent} = events(iEvent).times(I);
        end
    end

end
