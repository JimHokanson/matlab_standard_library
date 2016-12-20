classdef (Hidden) epoch < sci.time_series.subset_options.main_subset_option
    %
    %   Class:
    %   sci.time_series.subset_options.epoch
    
    properties
        epoch_name
        indices
        
        %These are optional
        percent
        time_offsets
        sample_offsets
    end
    
    methods
        function obj = epoch()
        end
        function [start_samples,stop_samples,other_options] = getStartAndStopSamples(obj,data_objects)
            
            n_objects = length(data_objects);
            start_times = cell(1,n_objects);
            stop_times = cell(1,n_objects);
            
            %Note, that we have 1 event for each 
            events = data_objects.getEvent(obj.epoch_name);
            
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
            
            %Change times to samples
            %-----------------------
            start_samples = obj.timesToSamples(data_objects,start_times);
            stop_samples  = obj.timesToSamples(data_objects,stop_times);


            %Implement sample based window
            %-----------------------------
            if ~isempty(obj.sample_offsets)
                start_samples = cellfun(@(x) x + obj.sample_offsets(1),start_samples,'un',0);
                stop_samples  = cellfun(@(x) x + obj.sample_offsets(2),stop_samples,'un',0);
            end
            
            [start_samples,stop_samples] = obj.processSplits(start_samples,stop_samples);
            other_options = obj.getOtherOptions();
        end
    end
    
end

