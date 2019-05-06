classdef event_processor < sci.time_series.subset_retrieval.processor
    %
    %   Class:
    %   sci.time_series.subset_retrieval.event_processor
    %
    %   The main access point is meant to be in:
    %       sci.time_series.subset_retrieval
    %

    %
    %   Global Optional Inputs
    %   ----------------------
    %   These optional inputs can be added to any of the inputs.
    %
    %   un: (default true)
    %   align_time_to_start: (default false)
    %   start_indices: 'all', scalar, array, or function handle
    %       When a function handle is used, the start event is passed
    %       in and times must be returned.
    %       e.g. start_indices = @(x)x.times(strcmp(x.msgs,'my_marker'));
    %       Use times where the message is 'my_marker'
    %   n_parts: 
    %       If specified, the resulting subset is further split into
    %       the specified number of parts.
    %   split_percentages:
    %       NYI - the idea is to specify locations to split.
    %
    %   Supported Calling Forms
    %   -----------------------
    %   1) start_event, stop_event              fromStartAndStopEvent       (stop_indices)
    %   2) start_event, time_offsets            fromEventAndTimeWindow      
    %   3) start_event, sample_offsets          fromEventAndSampleWindow      
    %   4) start_event, time_duration           fromEventAndTimeDuration
    %   5) start_event, sample_duration         fromEventAndSampleDuration
    %
    %   Examples
    %   --------
    %   1) 
    %   
    %   See Also
    %   --------
    %   sci.time_series.subset_retrieval
    
    
    properties
        d0 = '---------  Must have values -----------'
        start_name
        start_indices = 'all';
        un = true;
        align_time_to_start = false;
        
        d1 = '-------- Optional ---------'
        stop_name
        stop_indices = 'all';
        time_duration
        sample_duration
        time_offsets  %This is either:
        %1) No stop_name defined
        %start_time + time_offsets(1) to start_time + time_offsets(2) OR
        %2) stop_name is defined
        %start_time + time_offsets(1) to stop_time + time_offsets(2)
        sample_offsets
    end
    
    methods
        function [start_samples,stop_samples] = getStartAndStopSamples(obj,data_objects)
            %
            %   This is required method for data subset retrieval
            %
            %   [start_samples,stop_samples] = getStartAndStopSamples(obj,data_objects)
            %
            %   See Also
            %   --------
            %   sci.time_series.subset_retrieval.processor>getSubset
            
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
                if ~isempty(obj.stop_name)
                  	stop_events = data_objects.getEvent(obj.stop_name);
                    stop_times = h__process_indices(obj,obj.stop_indices,n_objects,stop_events);
                    stop_times = cellfun(@(x) x + obj.time_offsets(2),stop_times','un',0);
                else
                    stop_times = cellfun(@(x) x + obj.time_offsets(2),start_times','un',0);
                end
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
                %TODO: This needs to respect the stop name
                if ~isempty(obj.stop_name)
                   error('Unhandled code case') 
                end
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
