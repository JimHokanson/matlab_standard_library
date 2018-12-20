classdef processor < handle
    %
    %   Class:
    %   sci.time_series.subset_retrieval.processor
    %
    %   Abstract class which has shared code for more specific processors.
    %
    %   See Also
    %   --------
    %   sci.time_series.subset_retrieval
    %   sci.time_series.subset_retrieval.event_processor
    %   sci.time_series.subset_retrieval.epoch_processor
    
    properties
        %NYI, every subset_retrieval method should populate this ...
        %Although we also have optional inputs
        %-perhaps we convert the input to string
        %e.g. (fromEvent
        history
        
      	n_parts
        
        %TODO: NYI
        truncation_rule = 0
        %0 - always silent
        %1 - error if only event is present
        %2 - always an error
        
        %NYI
        split_percentages
    end
    
    methods (Abstract)
        %Implementations
        %-----------------
        %sci.time_series.subset_retrieval.generic_processor.getStartAndStopSamples
        [start_samples,stop_samples] = getStartAndStopSamples(obj,data_objects)
        %start_samples & stop_samples : {1 x n_objects}[1 x n_times]
    end
    
    methods
        function data_subset_objs = getSubset(obj,objs)
            %
            %   This is the final method that retrieves the actual data
            %   subset.
            
            
            %Note this is an abstract implementation ...
            %See:
            %   sci.time_series.subset_retrieval.generic_processor>getStartAndStopSamples
            [start_samples,stop_samples] = obj.getStartAndStopSamples(objs);
            %start_samples & stop_samples : {1 x n_objects}[1 x n_times]
            
            
            %TODO: This misses NaN values, which occurs if there is no
            %data and more specifically, if the time object is not well
            %specified (start_offset and dt are invalid)
            obj.h__checkValiditySamples(start_samples,stop_samples);
            
            return_as_cell = ~obj.un;
            if ~return_as_cell
                if any(cellfun('length',start_samples) ~= 1)
                    if all(cellfun('length',start_samples) == 0)
                        error('The requested event or epoch returned no times')
                    else
                        error('Sorry, please add ,''un'',0 at the end of the to the input (output will be a cell array, 1 entry per object')
                    end
                end
            end
            
            % if in.align_time_to_start
            %     first_sample_time = 0;
            % else
            %     %This basically means keep the first sample at whatever
            %     %time it currently is
            %     first_sample_time = [];
            % end
            
            n_objs = length(start_samples);
            temp_objs_1 = cell(1,n_objs);
            for iObj = 1:n_objs
                cur_obj = objs(iObj);
                
                cur_start_samples = start_samples{iObj};
                cur_stop_samples = stop_samples{iObj};
                
                %We might have multiple subsets for a single object ...
                n_spans = length(cur_start_samples);
                
                new_time_objs = cell(1,n_spans);
                temp_objs_2 = cell(1,n_spans);
                for iSpan = 1:n_spans
                    start_I  = cur_start_samples(iSpan);
                    stop_I   = cur_stop_samples(iSpan);
                    
                    %TODO: Decide if this is what we want to do ...
                    %
                    %   Behavior needs to be documented ...
                    if stop_I > cur_obj.n_samples
                        stop_I = cur_obj.n_samples;
                    end
                    new_data = cur_obj.d(start_I:stop_I,:,:);
                    
                    
                    n_samples = stop_I - start_I + 1;
                    new_time = cur_obj.time.getNewTimeObjectForDataSubset(start_I,n_samples);
                    new_time_objs{iSpan} = new_time;
                    
                    
                    new_obj = obj.h__createNewDataFromOld(cur_obj,new_data,new_time);
                    %new_obj.event_info.shiftTimes(new_obj.time.start_offset - cur_obj.time.start_offset)
                    temp_objs_2{iSpan} = new_obj;
                end
                
                %objs.zeroTimeByEvent(event_times)
                
                %We can always collapse these objects.
                %*** It is just across objects that we might not be able to collapse
                new_time_objs = [new_time_objs{:}];
                temp_objs_2_array = [temp_objs_2{:}];
                if obj.align_time_to_start
                    temp_objs_2_array.zeroTimeByEvent([new_time_objs.start_offset]);
                end
                
                temp_objs_1{iObj} = temp_objs_2_array;
            end
            
            if return_as_cell
                data_subset_objs = temp_objs_1;
            else
                data_subset_objs = [temp_objs_1{:}];
            end
            
        end
    end
    
    methods 
        function [start_samples,stop_samples] = processSplits(obj,start_samples,stop_samples)
            %This can be called by objects after the samples have been
            %resolved to split the subset into smaller subsets ...
            if ~isempty(obj.n_parts) || ~isempty(obj.split_percentages)
                %1) Verify singular times ...
                split_eligible = all(cellfun('length',start_samples) == 1);
                if ~split_eligible
                    error('Objects are not split eligible, splitting requires only a single start/stop pair for each object')
                end
                
                obj.un = false;
                
                if ~isempty(obj.n_parts)
                    
                    %TODO: see sl.array.split
                    %make sl.array.getSplitIndices
                    
                    [start_samples,stop_samples] = ...
                        cellfun(@(x,y) sl.array.split.getSplitIndices(x,y,'n_parts',obj.n_parts),...
                        start_samples,stop_samples,'un',0);
                else
                    error('Not yet implemented')
                end
            end
        end
    end
    
    methods (Static)
        function samples = timesToSamples(data_objs,times,varargin)
            %
            %   Inputs
            %   ------
            %   data_objs : sci.time_series.data
            %   times: cell array, 1 for each object
            %   
            
            in.relative_time = false;
            in = sl.in.processVarargin(in,varargin);
            
            n_objs = length(data_objs);
            samples = cell(1,n_objs);
            for iObj = 1:n_objs
                cur_obj = data_objs(iObj);
                cur_times = times{iObj};
                %sci.time_series.time
                %ftime : sci.time_series.time_functions
                samples{iObj} = cur_obj.ftime.getNearestIndices(cur_times,...
                    'relative_time',in.relative_time);
            end
        end
    end
    methods (Static)
        function new_data_obj = h__createNewDataFromOld(old_obj,new_data,new_time_object)
            %
            %   This should be used internally when creating a new data object.
            %
            %   Inputs:
            %   -------
            %   new_data : array
            %       The actual data from the new object.
            %   new_time_object : sci.time_series.time
            
            %This should be a method of data ...
            new_data_obj   = copy(old_obj,'raw_data',new_data,'time',new_time_object);
            %new_data_obj.d = new_data;
            %new_data_obj.time = new_time_object;
            %new_data_obj.event_info.shiftTimes(new_data_obj.time.start_offset - old_obj.time.start_offset)
        end
        
        function h__checkValiditySamples(start_samples,stop_samples)
            %start_samples & stop_samples : {1 x n_objects}[1 x n_times]
            %Here we are checking that all stop samples come after the start samples
            for iObj = 1:length(start_samples)
                obj_start_samples = start_samples{iObj};
                obj_stop_samples  = stop_samples{iObj};
                if any(obj_stop_samples < obj_start_samples)
                    error('Invalid range requested for object #%d',iObj)
                end
            end
            
        end
    end
    
end



