classdef data < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.data
    %
    %   This class is meant to bind data and an associated timeline.
    %   Generally these two things are held onto separately, even though
    %   they are closely related.
    %
    %   Time manipulations done in this class are automatically tracked by
    %   the class. Aditionally, functions that require time information
    %   (such as filtering) are automatically provided such information by
    %   the class.
    %
    %   Finally, there is some expectation that data stored in this class
    %   could be large, so there are some aspects of this class that try
    %   and handle this better than might typically be done by the user.
    %
    %   Methods to implement:
    %   ---------------------
    %   - allow merging of multiple objects (input as an array or cell
    %       array) into a single object - must have same length and time
    %       and maybe units
    %   - allow plotting of channels as stacked or as subplots
    %
    %
    %   Examples:
    %   ---------
    %   1) wtf = sci.time_series.data(rand(1e8,1),0.01);
    %
    %
    %   See Also:
    %   sci.time_series.tests_data
    %   sci.time_series.time
    
    properties
        d    %[samples x channels x repetitions]
        %
        %   This is the actual data. In general it is preferable to retrieve
        %   the data via:
        %
        %       obj.getRawDataAndTime()
        
        time     %sci.time_series.time
        units    %string
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
        n_channels
        n_reps
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
        function value = get.n_channels(obj)
            value = size(obj.d,2);
        end
        function value = get.n_reps(obj)
            value = size(obj.d,3);
        end
    end
    
    %Constructor ----------------------------------------------------------
    methods
        function obj = data(data_in,time_object_or_dt,varargin)
            %
            %   Calling Forms:
            %   --------------
            %   obj = sci.time_series.data(data_in,time_object,varargin)
            %
            %   obj = sci.time_series.data(data_in,dt,varargin)
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
            
            % :/ for initialization from structures
            if nargin == 0
                return
            end
            
            MIN_CHANNELS_FOR_WARNING = 500; %The dimensions of the input
            %data are very specific, no assumptions are made. However, if
            %we get too many channels with only 1 sample we'll throw a
            %warning.
            
            in.history = {};
            in.units   = 'Unknown';
            in.channel_labels = ''; %TODO: If numeric, change to string ...
            in.events  = [];
            in.y_label = '';
            in = sl.in.processVarargin(in,varargin);
            
            obj.d = data_in;
            
            if obj.n_samples == 1 && obj.n_channels >= MIN_CHANNELS_FOR_WARNING
                sl.warning.formatted(['Current specification for the data is' ...
                    ' to have %d channels all with 1 sample, perhaps you meant' ...
                    ' to transpose the input so that you have %d samples for 1 channel'],...
                    obj.n_channels,obj.n_channels)
            end
            
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
            obj.units   = in.units;
            obj.channel_labels = in.channel_labels;
            obj.history = in.history;
        end
        function new_objs = copy(old_objs)
            %x Creates a deep copy of the object
            %
            %   This allows someone to make changes to the properties
            %   without it also changing the original object.
            %
            %
            
            n_objs    = length(old_objs);
            temp_objs = cell(1,n_objs);
            
            for iObj = 1:n_objs
                cur_obj = old_objs(iObj);
                temp_objs{iObj} = sci.time_series.data(...
                    cur_obj.d,...
                    copy(cur_obj.time),...
                    'history',cur_obj.history,...
                    'units',cur_obj.units,...
                    'channel_labels',cur_obj.channel_labels,...
                    'events',cur_obj.devents,...
                    'y_label',cur_obj.y_label);
            end
            
            new_objs = [temp_objs{:}];
        end
        function s_objs = export(objs)
            %x Exports the object to a structure
            %
            %   Outputs:
            %   --------
            %   s_objs : structure array
            %
            s_objs = sl.obj.toStruct(objs);
            for iObj = 1:length(objs)
                s_objs(iObj).time = export(s_objs(iObj).time);
                
                events = s_objs(iObj).devents;
                fn = fieldnames(events);
                for iField = 1:length(fn)
                    cur_field_name = fn{iField};
                    events.(cur_field_name) = export(events.(cur_field_name));
                end
                s_objs(iObj).devents = events;
            end
        end
    end
    methods (Static)
        function objs = fromStruct(s_objs)
            %
            %
            %      
            
            n_objs  = length(s_objs);
            temp_ca = cell(1,n_objs);
            
            for iObj = 1:n_objs
                obj = sci.time_series.data;
                sl.struct.toObject(obj,s_objs(iObj));
                obj.time = sci.time_series.time.fromStruct(obj.time);
                temp_ca{iObj} = obj;
            end
            objs = [temp_ca{:}];
        end
    end
    
    %Visualization --------------------------------------------------------
    methods
        function plot(objs,local_options,plotting_options)
            %x Plot the data, nicely!
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
            %
            %   Example:
            %   plot(data_objs,{},{'Linewidth',2}
            %
            
            BIG_PLOT_N_SAMPLES = 5e5;
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
            
            in.axes     = {};
            in.channels = 'all';
            in = sl.in.processVarargin(in,local_options);
            
            if ~isempty(in.axes)
                in.axes = {in.axes};
            end
            
            for iObj = 1:length(objs)
                if iObj == 2
                    hold all
                end
                cur_obj = objs(iObj);
                %Ideally this decision would be pushed to the
                %LinePlotReducer class ...
                if cur_obj.n_samples < BIG_PLOT_N_SAMPLES
                    t = cur_obj.time.getTimeArray();
                    if ischar(in.channels)
                        plot(in.axes{:},t,cur_obj.d,plotting_options{:});
                    else
                        plot(in.axes{:},t,cur_obj.d(:,in.channels),plotting_options{:});
                    end
                else
                    if ischar(in.channels)
                        temp = sl.plot.big_data.LinePlotReducer(objs(iObj).time,objs(iObj).d,plotting_options{:});
                    else
                        temp = sl.plot.big_data.LinePlotReducer(objs(iObj).time,objs(iObj).d(:,in.channels),plotting_options{:});
                    end
                    if ~isempty(in.axes)
                        temp.h_axes = in.axes{1};
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
        function result_object = plotStacked(objs,local_options,plotting_options)
            %
            %
            %
            %   We could have variability between objects OR between
            %   channels, but not both
            
            %???? - How much should we shift by ????
            %Shifting ideas:
            %---------------
            %1) Fixed amount - specified by user
            %2) Fixed pct - specified by user - what would this be relative to
            
            %How to best get CDF??? - could be a rough estimate ...
            %
            %NOTE: For shifted lines, the CDF doesn't matter
            %    x
            %  x y   <= slanted lines, x & y, minimal distance needed
            %x y
            %y
            %   subtraction shifting
            %   - this requires the same time for each ... :/
            %
            %   TODO: For now let's assume this ...
            %
            %   Unless we go by the extreme, then we are still back at the
            %   CDF, although the CDF of the differences is much more
            %   informative
            %
            %   Although, we could do this for overlaps, don't care about
            %   the non overlaps !!!!
            %   Although, no overlaps should have some default separation
            %   ...
            %
            %   TODO: We also need to label which is which ...
            
            result_object = struct;
            
            if nargin < 2
                local_options = {};
            end
            if nargin < 3
                plotting_options = {};
            end
            
            in.shift    = []; %1 value or multiple values
            %multiple values, absolute or relative ????
            %- absolute for now ...
            in.channels = 'all'; %NYI
            in = sl.in.processVarargin(in,local_options);
            
            n_objs  = length(objs);
            
            %Step 1: Grab the data
            if n_objs > 1
                %Then plot each object shifted ...
                local_data = cell(1,n_objs);
                local_time = cell(1,n_objs);
                for iObj = 1:length(objs)
                    local_data{iObj} = objs(iObj).d;
                    local_time{iObj} = objs(iObj).time;
                end
            else
                obj = objs;
                n_chans = obj.n_channels;
                local_data = cell(1,n_chans);
                local_time = cell(1,n_chans);
                for iChan = 1:n_chans
                    local_data{iChan} = obj.d(:,iChan);
                    local_time{iChan} = obj.time;
                end
            end
            
            %Step 2: Determine shift amount
            
            n_plots = length(local_data);
            
            if isempty(in.shift)
                error('Currently this is required :/')
            elseif length(in.shift) == 1
                all_shifts    = zeros(1,n_plots);
                all_shifts(2:end) = in.shift;
                all_shifts    = cumsum(all_shifts);
            else
                all_shifts = in.shift;
            end
            
            result_object.all_shifts = all_shifts;
            
            hold all
            for iPlot = 1:n_plots
                temp = sl.plot.big_data.LinePlotReducer(local_time{iPlot},local_data{iPlot}+all_shifts(iPlot),plotting_options{:});
                temp.renderData();
            end
            hold off
            
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
        function objs = resample(objs,new_fs)
            
            %TODO: If nargout present, then copy, not replace           
           %TODO: Could expose filter options
           %TODO: 
           for iObj = 1:length(objs)
              cur_obj  = objs(iObj);
              old_fs = cur_obj.time.fs;
              if new_fs > old_fs
                  P = new_fs/old_fs;
                  %TODO: check integer
                  Q = 1;
              else
                  Q = old_fs/new_fs;
                  P = 1;
              end
                  
              cur_obj.d = resample(cur_obj.d,P,Q);
              cur_obj.time.dt = 1/new_fs;
              cur_obj.time.n_samples = cur_obj.n_samples;
           end
        end
        function objs = filter(objs,filters,varargin)
            %x Filter the data using filters specified as inputs
            %
            %   TODO: Provide a list of filters that can be used ...
            %   Filter List:
            %   -----------------------------------------------
            %   in sci.time_series.filter package
            %
            %   - butter   - i.e. sci.time_series.filter.butter
            %   - ellip
            %   - max
            %   - min
            %   - smoothing
            %
            %   Optional Inputs:
            %   ----------------
            %   subtract_filter_result : logical (Default false)
            %       If true, the returned signal is the result of taking
            %       the filtered signal and subtracting it from the
            %       original signal.
            %           i.e. data = data - filter(data)
            %
            %   See Also:
            %   sci.time_series.data_filterer
            
            in.subtract_filter_result = false;
            in = sl.in.processVarargin(in,varargin);
            
            df = sci.time_series.data_filterer('filters',filters);
            df.filter(objs,'subtract_filter_result',in.subtract_filter_result);
        end
        function decimated_data = decimateData(objs,bin_width,varargin)
            %x Resample time series after some smoothing function is applied
            %
            %   decimated_data = objs.decimateData(bin_width,varargin)
            %
            %   Currently decimation is done after taking the mean absolute
            %   value.
            %
            %   Inputs:
            %   -------
            %   bin_width : scalar (s)
            %       The width of each bin for decimation
            
            
            
            %in.max_samples = [];
            %in = sl.in.processVarargin(in,varargin);
            
            n_objs         = length(objs);
            decimated_data = cell(1,n_objs);
            
            for iObj = 1:n_objs
                cur_obj      = objs(iObj);
                sample_width = ceil(bin_width/cur_obj.time.dt);
                dt_exact     = cur_obj.time.dt*sample_width;
                
                
                n_samples = size(cur_obj.d,1);
                
                %We'll change this eventually to allow the last bin
                start_Is      = 1:sample_width:n_samples;
                start_Is(end) = []; %Drop the last one, might not be as accurate
                end_Is        = start_Is + sample_width-1;
                
                n_bins   = length(start_Is);
                new_data = zeros(n_bins,cur_obj.n_channels,cur_obj.n_reps);
                
                cur_data = cur_obj.d;
                
                new_obj  = cur_obj.copy();
                
                for iBin = 1:n_bins
                    temp_data = cur_data(start_Is(iBin):end_Is(iBin),:,:);
                    %NOTE: Eventually we might want additional methods
                    new_data(iBin,:,:) = mean(abs(temp_data),1);
                end
                
                new_time_object = copy(cur_obj.time);
                
                new_time_object.n_samples = n_bins;
                new_time_object.dt = dt_exact;
                new_time_object.shiftStartTime(dt_exact/2);
                
                new_data_obj = h__createNewDataFromOld(cur_obj,new_data,new_time_object);
                
                decimated_data{iObj} = new_data_obj;
            end
            
            decimated_data = [decimated_data{:}];
            
        end
        function runFunctionsOnData(objs,functions)
            %
            %
            %
            %   Example:
            %   --------
            %   objs.runFunctionsOnData(@abs)
            if iscell(functions)
                %Great, skip ahead
            elseif ischar(functions)
                functions = {str2func(functions)};
            elseif isa(functions, 'function_handle')
                functions = {functions};
            elseif ~iscell(functions)
                error('Unexpected type: %s, for ''functions'' input',class(functions));
            end
            
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                for iFunction = 1:length(functions)
                    cur_function = functions{iFunction};
                    cur_obj.d = cur_function(cur_obj.d);
                end
            end
        end
        function changeUnits(objs,new_units)
            %
            %   Inputs:
            %   -------
            %   new_units : string
            %
            %
            
            %TODO: We could make new_units a cell array of values, 1 for
            %each object
            
            %TODO: Check that all objs have the same units ...
            
            fh = sci.units.getConversionFunction(objs(1).units,new_units);
            
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                cur_obj.d = fh(cur_obj.d);
                cur_obj.units = new_units;
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
                
                new_time_object = h__getNewTimeObjectForDataSubset(cur_obj,start_index,end_index,'first_sample_time',first_sample_time);
                
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
        %         function sample_number = timeToSample(obj)
        %             error('Not yet implemented')
        %         end
        function removeTimeGapsBetweenObjects(objs)
            %
            %   removeTimeGapsBetweenObjects(objs)
            %
            %
            last_time = 0;
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                cur_obj.time.start_offset = last_time;
                last_time = cur_obj.time.end_time;
            end
        end
    end
    
    %Basic math functions --------------- e.g. abs
    %
    %   NOTE: I'm slowly adding onto these methods as I need them
    methods (Hidden)
        function objs = meanSubtract(objs)
           for iObj = 1:length(objs)
              cur_obj   = objs(iObj);
              cur_obj.d = bsxfun(@minus,cur_obj.d,mean(cur_obj.d));
           end
        end
        function objs = abs(objs)
            objs.runFunctionsOnData({@abs});
        end
        function objs = mrdivide(objs,B)
            objs.runFunctionsOnData({@(x)mrdivide(x,B)});
        end
        function objs = power(objs,B)
            objs.runFunctionsOnData({@(x)power(x,B)});
        end
    end
    
    %Deep methods
    %These methods are meant to provide access to functions that
    %work with this object. Rather than providing an exhaustive list, we
    %return an object that can be used to
    methods
        function event_calc_obj = getEventCalculatorMethods(objs)
            event_calc_obj = sci.time_series.event_calculators;
        end
        function spect_calc = getSpectrogramCalculatorMethods(objs)
           %sci.time_series.spectrogram_calculators 
           spect_calc = sci.time_series.spectrogram_calculators;
        end
    end
end

%Helper functions ---------------------------------------------------------
function new_data_obj = h__createNewDataFromOld(obj,new_data,new_time_object)
%
%   This should be used internally when creating a new data object.
%
%   Inputs:
%   -------
%   new_data : array
%       The actual data from the new object.
%   new_time_object : sci.time_series.time

new_data_obj   = copy(obj);
new_data_obj.d = new_data;
new_data_obj.time = new_time_object;
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
function new_time_object = h__getNewTimeObjectForDataSubset(obj,first_sample,last_sample,varargin)
%
%
%   Optional Inputs:
%   ----------------

in.first_sample_time = [];
%empty - keeps its time
%0 - first value will be zero
in = sl.in.processVarargin(in,varargin);

n_samples = last_sample - first_sample + 1;
new_time_object = obj.time.getNewTimeObjectForDataSubset(first_sample,n_samples,...
    'first_sample_time',in.first_sample_time);

end