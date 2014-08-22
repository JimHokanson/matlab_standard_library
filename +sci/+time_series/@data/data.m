classdef data < sl.obj.handle_light
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
        history = {} %Right now this is an arbitrary cell array that can
        %be added to as necessary using:
        %
        %   addHistoryElements()
        %
        %It is meant to help track the source of data and how it is
        %processed
        devents %Container with class: sci.time_series.time_events
        %
        %   See: addEventElements()
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
            %   Inputs:
            %   -------
            %   data_in: array [samples x channels]
            %   time_object_or_dt:
            %
            %   Optional Inputs:
            %   ----------------
            %   history:
            %   units:
            %   channel_labels:
            %   events: array or cell array of sci.time_series.time_events
            %
            %    data_in must be with samples going down the rows
            
            in.history = {};
            in.units = 'Unknown';
            in.channel_labels = ''; %TODO: If numeric, change to string ...
            in.events = [];
            in = sl.in.processVarargin(in,varargin);
            
            obj.n_channels = size(data_in,2);
            
            obj.d = data_in;
            
            if isobject(time_object_or_dt)
                obj.time = time_object_or_dt;
            else
                obj.time = sci.time_series.time(time_object_or_dt,obj.n_channels);
            end
            
            obj.devents = containers.Map();
            if ~isempty(in.events)
                obj.addEventElements(in.events);
            end
            
            obj.units = in.units;
            
            obj.history = in.history;
        end
        function plot(objs,local_options,plotting_options)
            %
            %
            %   TODO: How do we want to plot multiple repetitions ...
            %
            %   plot(obj,local_options,plotting_options)
            %
            %   Local Options: cell array
            %   -------------------------
            %   channels: default 'all'
            %       Pass in the numeric values of the channels to plot.
            %
            %   Plotting Options: cell array
            %   ----------------------------
            
            if nargin < 2
                local_options = {};
            end
            if nargin < 3
                plotting_options = {};
            end
            
            in.channels = 'all';
            in = sl.in.processVarargin(in,local_options);
            
            for iObj = 1:length(objs)
                if iObj == 2
                    hold all
                end
                if ischar(in.channels)
                    temp = sl.plot.big_data.LinePlotReducer(objs(iObj).time,objs(iObj).d,plotting_options{:});
                else
                    temp = sl.plot.big_data.LinePlotReducer(objs(iObj).time,objs(iObj).d(:,in.channels),plotting_options{:});
                end
                temp.renderData();
            end
            
            %TODO: Do this only if not already in this state
            %i.e. don't disable it if it wasn't enabled
            hold off
            
            %TODO: Add labels ...
        end
    end
    %Adding things --------------------------------
    methods
        function addEventElements(obj,event_elements)
            %
            %    Inputs:
            %    -------
            %    event_elements : cell or cell array of sci.time_series.time_events
            
            if iscell(event_elements)
                event_elements = [event_elements{:}];
            end
            
            for iElement = 1:length(event_elements)
                cur_element = event_elements(iElement);
                obj.devents(cur_element.name) = cur_element;
            end
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
    end
    %Data changing --------------------------------------------------------
    methods
        function filter(obj,filters)
            df = sci.time_series.data_filterer('filters',filters);
            df.filter(obj);
        end
    end
    
    methods
        function zeroTimeByEvent(objs,event_name_or_time_array)
           %
           %    Inputs:
           %    -------
           %    event_name_or_time_array: char or array
           %        If a string, this refers to one of the internal events
           %        in the system.
           
           
           
           n_objects = length(objs);
           if isnumeric(event_name_or_time_array)
               event_times = event_name_or_time_array;
           else
               event_times = zeros(1,n_objects);
               for iObj = 1:n_objects
                   temp_event_obj = objs(iObj).devents(event_name_or_time_array);
                   if length(temp_event_obj.times) ~= 1
                       error('Each event must have only 1 time value ..., for now')
                   end
                   event_times(iObj) = temp_event_obj.times;
               end
           end
           
           for iObj = 1:n_objects
              objs(iObj).time.start_offset = objs(iObj).time.start_offset - event_times(iObj); 
           end
           
           %TODO: We need to zero the times in the events as well ...
           
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
            
            %TODO: Should match class: zeros(a,b,'single') etc ...
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

