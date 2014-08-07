classdef data < handle
    %
    %   Class:
    %   sci.time_series.data
    %
    %
    %   Methods to implement:
    %   - allow merging of multiple objects (input as an array or cell
    %       array) into a single object - must have same length and time
    %       and maybe units
    %   - allow plotting of channels as stacked or as subplots
    %   - averaging to a stimulus
    
    properties
        d    %numeric array
        time     %sci.time_series.time
        units
        n_channels
    end
    
    properties
        history = {}
    end
    
    %Optional properties -------------------------------------------------
    properties
        
    end
    
    methods
        function obj = data(data_in,time_object_or_dt,varargin)
            %
            %    How to handle multiple channels?
            %
            %    obj = sci.time_series.data(data_in,time_object,varargin)
            %
            %    obj = sci.time_series.data(data_in,dt,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   history:
            %   units:
            %   channel_labels:
            %
            %    data_in must be with samples going down the rows
            
            in.history = {};
            in.units = 'Unknown';
            in.channel_labels = ''; %TODO: If numeric, change to string ...
            in = sl.in.processVarargin(in,varargin);
            
            obj.n_channels = size(data_in,2);
            
            obj.d = data_in;
            
            if isobject(time_object_or_dt)
                obj.time = time_object_or_dt;
            else
                obj.time = sci.time_series.time(time_object_or_dt,obj.n_channels);
            end
            
            obj.units = in.units;
            
            obj.history = in.history;
        end
        function plot(obj,local_options,plotting_options)
            %
            %
            %   TODO: How do we want to plot multiple repetitions ...
            %
            %   Optional Inputs:
            %   - Pass in as a cell array for the second input.
            %   ----------------
            %   channels: default 'all'
            %       Pass in the numeric values of the channels to plot.
            %
            
            
            in.channels = 'all';
            in = sl.in.processVarargin(in,local_options);
            
            if ischar(in.channels)
                temp = sl.plot.big_data.LinePlotReducer(obj.time,obj.d,plotting_options{:});
            else
                temp = sl.plot.big_data.LinePlotReducer(obj.time,obj.d(:,in.channels),plotting_options{:});
            end
            temp.renderData();
        end
        function addHistoryElements(obj,history_elements)
            if iscell(history_elements);
                if size(history_elements,2) > 1
                    history_elements = history_elements';
                end
            elseif ~ischar(history_elements)
                error('Invalid history element type')
            end
            
            obj.history = [obj.history; history_elements];
        end
        function event_aligned_data = getDataAlignedToEvent(obj,event_times,new_time_range,varargin)
            %
            %
            %    Inputs:
            %    -------
            %    event_times:
            %    new_time_range: [min max] with 0 being the event times
            %
            %    Optional Inputs:
            %    ----------------
            %    allow_overlap:
            %
            
            %TODO: Add history support ...
            
            if size(obj.d,3) ~= 1
                error('Unable to compute aligned data when the 3rd dimension is not of size 1')
            end
            
            %TODO: Check for no events ...
            
            %???? - how should we adjust for time offsets where our
            %event_times are occuring between samples ????
            
            %What options do we want to implement ...
            
            %We could allow time range
            
            %TODO: What if things are out of range ...
            
            in.allow_overlap = true;
            in = sl.in.processVarargin(in,varargin);
            
            [indices,time_errors] = obj.time.getNearestIndices(event_times);
            
            start_index_1 = obj.time.getNearestIndices(event_times(1)+new_time_range(1));
            end_index_1 = obj.time.getNearestIndices(event_times(1)+new_time_range(2));
            
            dStart_index = indices(1) - start_index_1;
            dEnd_index   = end_index_1 - indices(1);
            
            n_samples_new = dEnd_index + dStart_index + 1;
            
            data_start_indices = indices - dStart_index;
            data_end_indices   = indices + dEnd_index;
            
            n_events = length(event_times);
            
            %TODO: Should match class
            new_data = zeros(n_samples_new,obj.n_channels,n_events);
            cur_data = obj.d;
            %TODO: Is this is rate limiting step, should we mex it ????
            for iEvent = 1:n_events
                cur_start = data_start_indices(iEvent);
                cur_end   = data_end_indices(iEvent);
                new_data(:,:,iEvent) = cur_data(cur_start:cur_end,:);
            end
            
            %TODO: This needs to be cleaned up ...
            %Ideally we could call a copy object method ...
            
            new_time_object = obj.time.getNewTimeObjectForDataSubset(new_time_range(1),n_samples_new);
            
            event_aligned_data = sci.time_series.data(new_data,new_time_object);
            
        end
        function [data,time] = getRawDataAndTime(obj)
           data = obj.d;
           time = obj.time.getTimeArray();
        end
    end
end

