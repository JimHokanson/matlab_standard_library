classdef data < sl.obj.display_class
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
    %
    %
    %   Examples:
    %   ---------
    %   1) wtf = sci.time_series.data(rand(1e8,1),0.01);
    
    properties
        d    %[samples x channels x repetitions]
        %
        %   This is the actual data. In general it is preferable to retrieve
        %   the data via:
        %
        %       obj.getRawDataAndTime()
        
        time     %sci.time_series.time
        units
        n_channels
        n_reps
        channel_labels
        y_label %Must be a string
    end
    
    %Add on properties ----------------------------------------------------
    properties
        history = {} %Right now this is an arbitrary cell array that can
        %be added to as necessary using:
        %
        %   addHistoryElements()
        %
        %It is meant to help track the source of data and how it is
        %processed. As classes create or manipulate the data they can add
        %on to the history.
        
        devents %struct with fields of type: sci.time_series.time_events
        %
        %   See: addEventElements()
        %
        %   Shorts for "discrete events". I would prefer just to call this
        %   field events but that is a reserved word. These hold times in
        %   which certain things occured. The idea was that we could use
        %   this information for plotting or data manipulation.
        
    end
    
    properties (Dependent)
        event_names
        n_samples
    end
    
    %Dependent Methods ----------------------------------------------------
    methods
        function value = get.event_names(obj)
            value = fieldnames(obj.devents);
        end
        function value = get.n_samples(obj)
           value = size(obj.d,1); 
        end
    end
    
    %Constructor ----------------------------------------------------------
    methods
        function obj = data(data_in,time_object_or_dt,varargin)
            %
            %    obj = sci.time_series.data(data_in,time_object,varargin)
            %
            %    obj = sci.time_series.data(data_in,dt,varargin)
            %
            %   Inputs:
            %   -------
            %   data_in: array [samples x channels]
            %       data_in must be with samples going down the rows.
            %   time_object_or_dt: number or sci.time_series.time
            %
            %   Optional Inputs:
            %   ----------------
            %   history: cell array
            %       See description in class
            %   units: str
            %       Units of the data
            %   channel_labels:
            %       Not yet implemented
            %   events: array or cell array of sci.time_series.time_events
            %       These signify discrete events that happen at a given
            %       time and that may also carray a string or value with
            %       the event.
            %   y_label: string
            %       Value for y_label when plotted. 
            %
            %    
            
            in.history = {};
            in.units   = 'Unknown';
            in.channel_labels = ''; %TODO: If numeric, change to string ...
            in.events  = [];
            in.y_label = '';
            in = sl.in.processVarargin(in,varargin);
                        
            obj.n_channels = size(data_in,2);
            obj.n_reps     = size(data_in,3);
            
            obj.d = data_in;
            
            if isobject(time_object_or_dt)
                obj.time = time_object_or_dt;
            else
                obj.time = sci.time_series.time(time_object_or_dt,obj.n_samples);
            end
            
            obj.devents = struct();
            if ~isempty(in.events)
                obj.addEventElements(in.events);
            end
            
            obj.y_label = in.y_label;
            obj.units = in.units;
            obj.channel_labels = in.channel_labels;
            obj.history = in.history;
        end
        function new_objs = copy(old_objs)
            
            %TODO: Eventually delink the history and events as well
            n_objs = length(old_objs);
            temp_objs = cell(1,n_objs);
            for iObj = 1:n_objs
                cur_obj = old_objs(iObj);
                temp_objs{iObj} = sci.time_series.data(cur_obj.d,copy(cur_obj.time),...
                    'history',cur_obj.history,'units',cur_obj.units,...
                    'channel_labels',cur_obj.channel_labels,'events',cur_obj.devents);
            end
            
            new_objs = [temp_objs{:}];
        end
    end
    
    %Visualization --------------------------------------------------------
    methods
        function plot(objs,local_options,plotting_options)
            %
            %
            
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
            
            BIG_PLOT_N_SAMPLES = 1e7;
            %TODO: Plotting multiple objects on the same figure is a
            %problem as they may have completely different starting dates
            %
            %   TODO: How do we want to plot multiple repetitions ...
            
            if nargin < 2
                local_options = {};
            end
            if nargin < 3
                plotting_options = {};
            end
            
            %TODO: Determine x bounds and set them before hand
            %I want to prevent x axis changing redraws
            %
            %Perhaps I can disable plotting until all objects have plotted
            %...
            
            in.channels = 'all';
            in = sl.in.processVarargin(in,local_options);
            
            for iObj = 1:length(objs)
                if iObj == 2
                    hold all
                end
                cur_obj = objs(iObj);
                %This might be temporary if I can fix LinePlotReducer to
                %not constantly replot ...
                if cur_obj.n_samples < BIG_PLOT_N_SAMPLES
                    t = cur_obj.time.getTimeArray();
                    if ischar(in.channels)
                        plot(t,cur_obj.d,plotting_options{:});
                    else
                        plot(t,cur_obj.d(:,in.channels),plotting_options{:});
                    end
                else
                    if ischar(in.channels)
                        temp = sl.plot.big_data.LinePlotReducer(objs(iObj).time,objs(iObj).d,plotting_options{:});
                    else
                        temp = sl.plot.big_data.LinePlotReducer(objs(iObj).time,objs(iObj).d(:,in.channels),plotting_options{:});
                    end
                    temp.renderData();
                end
            end
            
            %TODO: Do this only if not already in this state
            %i.e. don't disable it if it wasn't enabled
            hold off
            
            %TODO: Depeneding upon what is defined, show different things
            %for the ylabel
            ylabel(sprintf('%s (%s)',cur_obj.y_label,cur_obj.units))
            xlabel(sprintf('Time (%s)',cur_obj.time.output_units))
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
            elseif isstruct(event_elements)
                %This occurs when copying ...
                event_elements = struct2cell(event_elements);
                event_elements = [event_elements{:}];
            end
            
            for iElement = 1:length(event_elements)
                cur_element = event_elements(iElement);
                obj.devents.(cur_element.name) = cur_element;
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
        function filter(obj,filters,varargin)
            %
            %   This is a shortcut for calling the data_filterer.
            %
            %   TODO: Provide a list of filters that can be used ...
            %
            %   See Also:
            %   sci.time_series.data_filterer
            
            in.subtract_filter_result = false;
            in = sl.in.processVarargin(in,varargin);
            
            df = sci.time_series.data_filterer('filters',filters);
            df.filter(obj,'subtract_filter_result',in.subtract_filter_result);
        end
        function decimated_data = decimateData(objs,bin_width,varargin)
            
            %in.max_samples = [];
            %in = sl.in.processVarargin(in,varargin);
            
            n_objs = length(objs);
            decimated_data = cell(1,n_objs);
            
            for iObj = 1:n_objs
                cur_obj = objs(iObj);
                sample_width = ceil(bin_width/cur_obj.time.dt);
                
                n_samples = size(cur_obj.d,1);
                
                %We'll change this eventually to allow the last bin
                start_Is = 1:sample_width:n_samples;
                start_Is(end) = [];
                end_Is = start_Is + sample_width-1;
                
                n_bins = length(start_Is);
                new_data = zeros(n_bins,cur_obj.n_channels,cur_obj.n_reps);
                
                cur_data = cur_obj.d;
                for iBin = 1:n_bins
                    temp_data = cur_data(start_Is(iBin):end_Is(iBin),:,:);
                    %NOTE: Eventually we might change this ...
                    new_data(iBin,:,:) = mean(abs(temp_data));
                end

                decimated_data{iObj} = new_data;
            end
            
        end
    end
    
    %Time related manipulations -------------------------------------------
    methods
        function data_subset_objs = getDataSubset(objs,start_event,start_event_index,stop_event,stop_event_index,varargin)
            %
            %   Returns a new object that only has a subset of the data.
            %
            %   Calling Forms:
            %   --------------
            %   getDataSubset(objs,start_event,start_event_index,stop_event,stop_event_index,varargin)
            %
            %   getDataSubset(objs,start_time,[],stop_time,[],varargin)
            %
            %   Inputs:
            %   -------
            %
            %   Optional Inputs:
            %   ----------------
            %   align_time_to_start : logical (default false)
            %       If this value is true, the zero point of the time is
            %       shifted such that
            %
            %   See Also:
            %   sci.time_series.data.getDataAlignedToEvent()
            %   sci.time_series.data.zeroTimeByEvent()
            
            in.align_time_to_start = false;
            in = sl.in.processVarargin(in,varargin);
            
            if in.align_time_to_start
                first_sample_time = 0;
            else
                %This basically means keep the first sample at whatever
                %time it currently is
                first_sample_time = [];
            end
            
            n_objs = length(objs);
            all_start_times = zeros(1,n_objs);
            temp_objs_ca = cell(1,n_objs);
            for iObj = 1:n_objs
                cur_obj = objs(iObj);
                
                start_time = cur_obj.devents.(start_event).times(start_event_index);
                end_time   = cur_obj.devents.(stop_event).times(stop_event_index);
                
                %TODO: Make this a function ...
                start_index = h__timeToSamples(cur_obj,start_time);
                end_index   = h__timeToSamples(cur_obj,end_time);
                
                new_data        = cur_obj.d(start_index:end_index,:,:);
                
                new_time_object = h__getNewTimeObject(cur_obj,start_index,end_index,'first_sample_time',first_sample_time);
                
                temp_objs_ca{iObj} = h__createNewDataFromOld(cur_obj,new_data,new_time_object);
            end
            
            data_subset_objs = [temp_objs_ca{:}];
            
            if in.align_time_to_start
                data_subset_objs.zeroTimeByEvent(all_start_times);
            end
        end
        function zeroTimeByEvent(objs,event_name_or_time_array)
            %
            %    Redefines time such that the time of event is now at time
            %    zero.
            %
            %    objs.zeroTimeByEvent(event_name)
            %
            %    objs.zeroTimeByEvent(event_times)
            %
            %    Inputs:
            %    -------
            %    event_name :
            %        This refers to one of the internal events in the object.
            %    event_times :
            %        A single event time should be provided for each object
            % 
            %   See Also:
            %   sci.time_series.data.getDataAlignedToEvent()
            %   sci.time_series.data.getDataSubset()
            
            n_objects = length(objs);
            if isnumeric(event_name_or_time_array)
                event_times = event_name_or_time_array;
            else
                event_times = zeros(1,n_objects);
                for iObj = 1:n_objects
                    temp_event_obj = objs(iObj).devents.(event_name_or_time_array);
                    if length(temp_event_obj.times) ~= 1
                        error('Each event must have only 1 time value ..., for now')
                    end
                    event_times(iObj) = temp_event_obj.times;
                end
            end
            
            %TODO: Make this a method in the time object - shift time
            for iObj = 1:n_objects
                %Adjust time start_offset
                objs(iObj).time.start_offset = objs(iObj).time.start_offset - event_times(iObj);
                
                %Adjust event times
                all_events = objs(iObj).devents;
                fn = fieldnames(all_events);
                for iField = 1:length(fn)
                    %all_events is just a structure
                    cur_event = all_events.(fn{iField});
                    cur_event.shiftStartTime(event_times(iObj));
                end
            end
            
        end
        function event_aligned_data = getDataAlignedToEvent(obj,event_times,new_time_range,varargin)
            %
            %   event_aligned_data = getDataAlignedToEvent(obj,event_times,new_time_range,varargin)
            %
            %   This function is useful for things like stimulus triggered
            %   averaging.
            %
            %   Inputs:
            %   -------
            %   event_times:
            %   new_time_range: [min max] with 0 being the event times
            %
            %   Optional Inputs:
            %   ----------------
            %   allow_overlap:  Not yet implemented ...
            %
            %
            %   Outputs:
            %   --------
            %   event_aligned_data
            %
            %   TODO: Provide an example of using this function.
            %
            %   See Also:
            %   sci.time_series.data.zeroTimeByEvent()
            %   sci.time_series.data.getDataSubset()
            
            %TODO: Build in multiple object support ...
            
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
            
            
            %TODO: Use h__getNewTimeObject
            
            start_index_1 = h__timeToSamples(obj,event_times(1)+new_time_range(1));
            end_index_1   = h__timeToSamples(obj,event_times(1)+new_time_range(2));
            
            dStart_index = indices(1) - start_index_1;
            dEnd_index   = end_index_1 - indices(1);
            
            n_samples_new = dEnd_index + dStart_index + 1;
            
            data_start_indices = indices - dStart_index;
            data_end_indices   = indices + dEnd_index;
            
            n_events = length(event_times);
            
            new_data = zeros(n_samples_new,obj.n_channels,n_events,'like',obj.d);
            cur_data = obj.d;
            %TODO: Is this is rate limiting step, should we mex it ????
            for iEvent = 1:n_events
                cur_start = data_start_indices(iEvent);
                cur_end   = data_end_indices(iEvent);
                new_data(:,:,iEvent) = cur_data(cur_start:cur_end,:);
            end
            
            %TODO: This needs to be cleaned up ...
            %Ideally we could call a copy object method ...
            
            new_time_object = obj.time.getNewTimeObjectForDataSubset(new_time_range(1),n_samples_new,'first_sample_time',new_time_range(1));
            
            event_aligned_data = sci.time_series.data(new_data,new_time_object);
            
        end
        function [data,time] = getRawDataAndTime(obj)
            data = obj.d;
            time = obj.time.getTimeArray();
        end
        function sample_number = timeToSample(obj)
            error('Not yet implemented')
        end
    end
end

%Helper functions ---------------------------------------------------------
function new_data = h__createNewDataFromOld(obj,new_data,new_time_object)
  new_data = sci.time_series.data(new_data,new_time_object);
end
function event_times = h__getEventTimes(obj,event_name,varargin)
%
%
%   See Also:
%   sci.time_series.time_events

%TODO: Create public method that retrieves a particular event

in.indices = 'all';
in = sl.in.processVarargin(in,varargin);

events = obj.devents;

%TODO: Check for name
if ~isfield(events,event_name)
    error('Requested event: %s, does not exist',event_name)
end

event_obj = events.(event_name);

if ischar(in.indices)
    event_times = event_obj.times;
else
    %Might surround with try/catch
    event_times = event_obj.times(in.indices);
end

end
function samples = h__timeToSamples(obj,times)
samples = obj.time.getNearestIndices(times);
end
function new_time_object = h__getNewTimeObject(obj,first_sample,last_sample,varargin)

in.first_sample_time = [];
%empty - keeps its time
%0 - first value will be zero
in = sl.in.processVarargin(in,varargin);

n_samples = last_sample - first_sample + 1;
new_time_object = obj.time.getNewTimeObjectForDataSubset(first_sample,n_samples,...
    'first_sample_time',in.first_sample_time);

end