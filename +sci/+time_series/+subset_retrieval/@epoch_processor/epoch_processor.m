classdef epoch_processor < sci.time_series.subset_retrieval.processor
    %
    %   Class:
    %   sci.time_series.subset_retrieval.epoch_processor
    %
    %   Accessed from:
    %   sci.time_series.subset_retrieval
    %
    %   See Also
    %   --------
    %   sci.time_series.subset_retrieval
    %   sci.time_series.subset_retrieval.processor
    %   sci.time_series.subset_retrieval.event_processor
    %   sci.time_series.epochs
    %   sci.time_series.discrete_events
    %
    %   This class returns data subsets for epochs
    %
    %   Supported Calling Forms
    %   -----------------------
    %   fromEpoch
    %   fromEpochAndPct
    %   fromEpochAndSampleWindow
    %   fromEpochAndTimeWindow
    %   
    
    properties
        d0 = '---------  Must have values -----------'
        %Name of the epoch. Either this or the object must
        %be passed in ...
        epoch_name 
        
        %sci.time_series.epochs
        epoch_object
        
        %Which epoch indices to use. Default 'all'
        indices = 'all'
        
        %Set this to false if:
        %1) multiple epoachs are being requested
        %2) 
        un = true;
        
        %I don't think this is used ...
        align_time_to_start = false;
        
        %TODO: d1 info is confusing, which calling form???
        d1 = '---------   Specific to calling form ------'
        %2 elements
        %t1 = start_time + percent(1)*time_range
        %t2 = stop_time + percent(2)*time_range
        %
        percent
        
        %2 elements
        %t1 = start_time + time_offsets(1)
        %t2 = start_time + time_offsets(2)
        time_offsets
        
        %2 elements
        %s1 = start_sample + sample_offsets(1)
        %s2 = start_sample + sample_offsets(2)
        sample_offsets
    end

    methods
        function [start_samples,stop_samples] = getStartAndStopSamples(obj,data_objects)
            %
            %   Method that specifies the first and last indices of the
            %   original data to use when grabbing a subset of data.
            %
            %   Called by
            %   ---------
            %   
            %
            %   Inputs
            %   ------
            %   data_objects : sci.time_series.data
            %
            %   Optional Inputs
            %   ---------------
            %   indices :
            %   
            %
            %   Outputs
            %   -------
            %   start_samples
            %   stop_samples
            
            
            n_objects = length(data_objects);
            start_times = cell(1,n_objects);
            stop_times = cell(1,n_objects);
            
            %Note, that we have 1 event for each
            if isempty(obj.epoch_name)
                if isempty(obj.epoch_object)
                    error('Epoch name and object properties are empty, one must be set')
                end
                events = obj.epoch_object;
            else
                events = data_objects.getEvent(obj.epoch_name);
            end
            
            %1) Retrieval of times ...
            %--------------------------------------------------------------
            if ischar(obj.indices)
                for iEvent = 1:n_objects
                    start_times{iEvent} = events(iEvent).start_times;
                    stop_times{iEvent}  = events(iEvent).stop_times;
                end
            else
                I = obj.indices;
                for iEvent = 1:n_objects
                    start_times{iEvent} = events(iEvent).start_times(I);
                    stop_times{iEvent}  = events(iEvent).stop_times(I);
                end
            end
            
            %Handle optional windowing - times now, samples later
            %-------------------------------------------------------------
            if ~isempty(obj.percent)
                range = cellfun(@(x,y) x-y,stop_times,start_times,'un',0);
                %Stop_times must come first before we redefine start_times
                stop_times  = cellfun(@(x,y) x + obj.percent(2)*y,start_times,range,'un',0);
                start_times = cellfun(@(x,y) x + obj.percent(1)*y,start_times,range,'un',0);
            elseif ~isempty(obj.time_offsets)
                start_times = cellfun(@(x) x + obj.time_offsets(1),start_times,'un',0);
                stop_times  = cellfun(@(x) x + obj.time_offsets(2),stop_times,'un',0);
            end
            %~isempty(obj.sample_offsets) => see below ...
            
            %Change times to samples
            %-----------------------
            %sci.time_series.subset_retrieval.processor>timesToSamples
            start_samples = obj.timesToSamples(data_objects,start_times);
            stop_samples  = obj.timesToSamples(data_objects,stop_times);
            
            
            %Implement sample based window
            %-----------------------------
            if ~isempty(obj.sample_offsets)
                start_samples = cellfun(@(x) x + obj.sample_offsets(1),start_samples,'un',0);
                stop_samples  = cellfun(@(x) x + obj.sample_offsets(2),stop_samples,'un',0);
            end
            
            [start_samples,stop_samples] = obj.processSplits(start_samples,stop_samples);
        end
    end
    
end

