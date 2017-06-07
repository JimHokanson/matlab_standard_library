classdef data < sl.obj.handle_light
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
    %   Handle vs Value Classing
    %   ------------------------
    %   This class is setup to be used as a handle class. It also however
    %   carries many of the usages of a value class. For example, you can
    %   compute the absolute value of the data.
    %
    %   When using math operations, it is typical to get a copy of the
    %   value, not to modify a value in place. In other words, let's say we
    %   have something like:
    %
    %       a = -1;
    %       b = abs(a);
    %
    %   In this case we would expect 'a' to have the value -1 still. But what
    %   if 'a' were a handle class. Then the assignment:
    %
    %       b = abs(a);
    %
    %   modifies the value of a, and passes the handle reference to b. Thus
    %   'a' would have the value 1.
    %
    %   Since this is generally not desirable, I'm trying to modify all
    %   functions that are of this nature so that the following happens:
    %
    %   Case 1: An output is requested, make a copy
    %   b = abs(a); a => -1, b => 1
    %
    %   Case 2: No output is requested, modify in place
    %   abs(a); a => 1
    %
    %   In other words, the presence of an output means that the handle
    %   should first be copied and then modified, so that the original
    %   value is not changed.
    %
    %
    %   See Also:
    %   sci.time_series.tests_data
    %   sci.time_series.time
    %
    %
    %   Examples:
    %   ---------
    %   1)
    %       wtf = sci.time_series.data(rand(1e8,1),0.01);
    %
    
    %Other Files:
    %-------------
    %sci.time_series.data.getDataSubset
    %sci.time_series.data.resample
    
    
    %{
    %   2)
          dt = 0.001;
          t  = -2:dt:2;
          time_obj = sci.time_series.time(dt,length(t));
          y = chirp(-2:dt:2,100,1,200,'q');
          wtf = sci.time_series.data(y',time_obj);
          sc = wtf.getSpectrogramCalculatorMethods;
          sd = sc.ml_spectrogram(wtf,dt*100);
          plot(sd)
    
    
          profile on
          for i = 1:20
          disp(wtf)
          end
          profile off
    
    
    %}
    
    
    properties
        d    %[samples x channels x repetitions]
        %
        %   This is the actual data. In general it is preferable to retrieve
        %   the data via:
        %
        %       obj.getRawDataAndTime()
        
        time     %sci.time_series.time
        units    %string
        channel_labels %cellstr (or string?)
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
        
        event_info %sci.time_series.events_holder
        %
        %   See: addEventElements()
        
    end
    
    properties (Dependent,GetObservable)
        event_names
        n_channels
        n_reps
        n_samples
        calculators %sci.time_series.calculators
        subset
        ftime
    end
    
%     methods
%         function preGet(varargin)
%             disp(length(varargin{1}))
%         end
%     end
    
    %Dependent Methods ----------------------------------------------------
    methods
        function value = get.event_names(obj)
            value = obj.event_info.p__all_event_names;
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
        function value = get.calculators(obj) %#ok<MANU>
            value = sci.time_series.calculators;
        end
        function value = get.subset(obj)
            %This only works well for a single object
            %TODO: use input_name and check for single value ...
            %- throw error if not a single object ...
            %crap - but then we run into indexing problems ...
           value = sci.time_series.subset_retrieval(obj); 
        end
        function value = get.ftime(obj)
           value = sci.time_series.time_functions(obj); 
        end
    end
    
    methods
        function value = subset_retriever(objs)
            %I added this on because the subset property
            %only works for scalar objects, not for object arays :/
            %
            %   Example Usage
            %   -------------
            %   sr = my_data_objects.subset_retriever;
            %   data_subsets = sr.fromEpoch('my_epoch');
            value = sci.time_series.subset_retrieval(objs); 
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
            %   data_in : array [samples x channels]
            %       'data_in' must be with samples going down the rows.
            %   time_object : sci.time_series.time
            %       Specification regarding the start time and sampling 
            %       rate of the data.
            %   dt: number
            %
            %   Optional Inputs:
            %   ----------------
            %   history: cell array
            %       See description in class
            %   units: str
            %       Units of the data
            %   channel_labels:
            %       Not yet implemented
            %   events: array or cell array of:
            %               - sci.time_series.discrete_events
            %               - sci.time_series.epochs
            %   y_label: string
            %       Value for y_label when plotted.
            
            %This is needed for initializing from a structure :/
            if nargin == 0
                return
            end
            
            MIN_CHANNELS_FOR_WARNING = 50; %The dimensions of the input
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
            
            if isobject(time_object_or_dt)
                if time_object_or_dt.n_samples ~= size(data_in,1)
                    %TODO: This may be because of a transpose error
                    %make the error clearer in that case (i.e.) that
                    %the tranpose of the data needs to be passed in
                    error('The # of samples in the data does not equal the # of samples specified in the time')
                end
            elseif obj.n_samples == 1 && obj.n_channels >= MIN_CHANNELS_FOR_WARNING
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
            
            obj.event_info = sci.time_series.events_holder;
            if ~isempty(in.events)
                obj.addEventElements(in.events);
            end
            
            obj.y_label = in.y_label;
            obj.units   = in.units;
            obj.channel_labels = in.channel_labels;
            obj.history = in.history;
        end
        function new_objs = copy(old_objs,varargin)
            %x Creates a deep copy of the object
            %
            %   new_objs = copy(old_objs)
            %
            %   This allows someone to make changes to the properties
            %   without it also changing the original object.
            %
            %   Optional Inputs
            %   ---------------
            %   raw_data : array or cell array of arrays
            %       NOTE, currently changing the # of channels is not
            %       supported with this approach.
            %   dt : scalar or array
            %       Inverse of the sampling rate
            %   new_start_offset : scalar or array
            %       AKA t0
            %
            %   See Also:
            %   ---------
            %   sci.time_series.events_holder
            %   sci.time_series.time
            
            in.units = {};
            in.raw_data = []; 
            in.dt = [];
            in.new_start_offset = [];
            in = sl.in.processVarargin(in,varargin);
            
            n_objs    = length(old_objs);
            temp_objs = cell(1,n_objs);
            
            if isempty(in.raw_data)
                local_n_samples = [];
                raw_data = {old_objs.d};
            elseif iscell(in.raw_data)
                local_n_samples = cellfun('length',in.raw_data);
                raw_data = in.raw_data;
            else
                local_n_samples = length(in.raw_data);
                raw_data = {in.raw_data};
            end
            
            if isempty(in.units)
                local_units = {old_objs.units};
            elseif iscell(in.units)
                local_units = in.units;
            else
                local_units = repmat({in.units},1,n_objs);
            end
            
            old_time_objs = [old_objs.time];
            new_time_objs = copy([old_objs.time],...
                'new_start_offset',in.new_start_offset,...
                'dt',in.dt,'n_samples',local_n_samples);
            
            for iObj = 1:n_objs
                time_shift = old_time_objs(iObj).start_offset-new_time_objs(iObj).start_offset;
                cur_obj = old_objs(iObj);
                temp_objs{iObj} = sci.time_series.data(...
                    raw_data{iObj},...
                    new_time_objs(iObj),...
                    'history',      cur_obj.history,...
                    'units',        local_units{iObj},...
                    'channel_labels',cur_obj.channel_labels,...
                    'events',       copy(cur_obj.event_info,'time_shift',time_shift),...
                    'y_label',      cur_obj.y_label);
            end
            
            new_objs = [temp_objs{:}];
        end
        function s_objs = export(objs)
            %x Exports the object to a structure
            %
            %   s_objs = export(objs)
            %
            %   Outputs:
            %   --------
            %   s_objs : structure array
            
            s_objs = sl.obj.toStruct(objs);
            for iObj = 1:length(objs)
                s_objs(iObj).time = export(s_objs(iObj).time);
                
                events = s_objs(iObj).event_info;
                fn = fieldnames(events);
                for iField = 1:length(fn)
                    cur_field_name = fn{iField};
                    events.(cur_field_name) = export(events.(cur_field_name));
                end
                s_objs(iObj).event_info = events;
            end
        end
    end
    methods (Static)
        function objs = fromStruct(s_objs)
            %x Creates an instance of the objects from a structure
            %
            %   objs = sci.time_series.data.fromStruct(s_objs)
            %
            %   This method was originally written when I had shared some
            %   data with
            %
            %   Example:
            %   --------
            %   s_objs = export(data_objs);
            %   new_objs = fromStruct(s_objs)
            
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
    
    %Display handlers -----------------------------------------------------
    methods
        function disp(objs)
            
            %I wanted to build in support for not showing
            %all of the links if we are doing a mouseover ...
            % msgbox('hi mom');
            %keyboard
            %wtf = sl.stack.calling_function_info();
            
            sl.obj.dispObject_v1(objs,'show_methods',false);
            
            SECTION_NAMES = {'constructor related','visualization','events and history','time changing','data changing','math','miscellaneous'};
            
            sl.obj.disp.sectionMethods(SECTION_NAMES,'sci.time_series.data.dispMethodsSection')
        end
    end
    methods (Static)
        function dispMethodsSection(section_name)
            %x Should display methods in a section
            %
            %    sci.time_series.data.dispMethodsSection
            %
            %    Inputs:
            %    -------
            %    section_name : string
            %        Options include:
            %            - 'constructor_related'
            %            - 'visualization'
            %            - 'events_and_history'
            %            - 'time changing'
            %            - 'data changing'
            %
            
            switch section_name
                case 'constructor related'
                    fcn_names = {'copy','export','fromStruct'};
                case 'visualization'
                    fcn_names = {'plotRows','plot','plotStacked'};
                case 'events and history'
                    fcn_names = {'getEvent','addEventElements','addHistoryElements'};
                case 'time changing'
                    %Not in this file:
                    %resample
                    fcn_names = {'resample','getDataSubset','zeroTimeByEvent','getDataAlignedToEvent','removeTimeGapsBetweenObjects'};
                case 'data changing'
                    fcn_names = {'meanSubtract','minSubtract','filter','decimateData','changeUnits'};
                case 'math'
                    fcn_names = {'add','minus','abs','mrdivide','power','max','min','sum'};
                case 'miscellaneous'
                    fcn_names = {'getRawDataAndTime'};
                otherwise
                    error('Unknown section name')
            end
            
            section_name = sl.str.capitalizeWords(section_name);
            header_name = sprintf('%s Methods:',section_name);
            sl.obj.disp.methods_v1('sci.time_series.data','header',header_name,'methods_use',fcn_names)
        end
    end
    
    %Visualization --------------------------------------------------------
    methods
        function varargout = plotRows(objs,varargin)
            %x Plots each object as a row
            %
            %   plot_results = plotRows(objs,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   link_option: (default 'x')
            %       - x   - link x axes of all plots
            %       - xy  - 
            %       - y
            %   Additional arguments can be specified via the 
            %
            %   Outputs:
            %   --------
            %   plot_results : sci.time_series.data.plot_result
            %       
            %
            %   Example:
            %   --------
            %   plotRows(p,'Linewidth',2,'link_options','xy')
            %
            %   See Also:
            %   ---------
            %   sci.time_series.data.plot
            

            plot_results = cell(1,length(objs));
            
            in.link_option = 'x';
            [local_options,plot_options] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
            in = sl.in.processVarargin(in,local_options);

            n_objs = length(objs);
            
            for iObj = 1:n_objs
                subplot(n_objs,1,iObj)
                plot_results{iObj} = plot(objs(iObj),plot_options{:});
            end
            
            sl.plot.postp.linkFigureAxes(gcf,in.link_option);
            
            if nargout
                varargout{1} = [plot_results{:}];
            end
            
            %TODO: Build in cleanup code ...
        end

        function result_object = plotStacked(objs,varargin)
            %
            %
            %   result_object = plotStacked(objs,local_options,plotting_options)
            %
            %   We could have variability between objects OR between
            %   channels, but not both
            %
            %   ====================================
            %   TODO: Update documentation!
            %   ====================================
            %
            %   Outputs:
            %   --------
            %   result_object : struct
            %       - line_handles: cell
            %
            %   Examples:
            %   ---------
            %   pres.zeroTimeByEvent('start_pump');
            %   r = pres.plotStacked('shift',-15,'Linewidth',2);
            %
            %   Improvements:
            %   -------------
            %   1) Add on labels in this command
            %   2) Add on a y-scale bar
            %
            
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
            
            in.y_tick_labels = {};
            in.zero_by_event = '';
            in.loop_props = {'Color'};
            in.shift    = []; %1 value or multiple values
            %multiple values, absolute or relative ????
            %- absolute for now ...
            in.channels = 'all'; %NYI
            in.time_units = 's';
            
            [varargin,plotting_options] = sl.in.removeOptions(varargin,fieldnames(in));
            
            in = sl.in.processVarargin(in,varargin);
            
            if ~isempty(in.zero_by_event)
               objs = objs.zeroTimeByEvent(in.zero_by_event); 
            end
            
            
            n_objs  = length(objs);
            
            %Step 1: Grab the data
            %-----------------------------------------------------
            if n_objs > 1
                %Then plot each object shifted ...
                local_data = cell(1,n_objs);
                local_time = cell(1,n_objs);
                for iObj = 1:length(objs)
                    local_data{iObj} = objs(iObj).d;
                    local_time{iObj} = copy(objs(iObj).time);
                end
            else
                %Plot each channel shifted ...
                obj = objs;
                n_chans = obj.n_channels;
                local_data = cell(1,n_chans);
                local_time = cell(1,n_chans);
                for iChan = 1:n_chans
                    local_data{iChan} = obj.d(:,iChan);
                    local_time{iChan} = copy(obj.time);
                end
            end
            
            local_time = [local_time{:}];
            local_time.changeOutputUnits(in.time_units);
            
            %Step 2: Determine shift amount
            %----------------------------------------------------------
            n_plots = length(local_data);
            
            if isempty(in.shift)
                error('Currently a shift specification is required :/')
            elseif length(in.shift) == 1
                all_shifts    = zeros(1,n_plots);
                all_shifts(2:end) = in.shift;
                all_shifts    = cumsum(all_shifts);
            else
                all_shifts = in.shift;
            end
            
            result_object.all_shifts = all_shifts;
            
            %Plotting
            %---------------------------------------------------
            line_handles = cell(1,n_plots);
            
            loop_options = sl.in.looped_options(plotting_options,in.loop_props);
            hold all
            for iPlot = 1:n_plots
                plotting_options = loop_options.getNext();
                temp = big_plot(local_time(iPlot),local_data{iPlot}+all_shifts(iPlot),plotting_options{:});
                temp.renderData();
                line_handles(iPlot) = temp.h_and_l.h_plot(1);
            end
            hold off
            
            set(gca,'YGrid','on')
            
            if ~isempty(in.y_tick_labels)
               set(gca,'YTick',all_shifts,'YTickLabel',in.y_tick_labels)
            end
            
            if ~isempty(in.zero_by_event)
               event_fixed = regexprep(in.zero_by_event,'_',' ');
               xlabel(sprintf('Time since %s (%s)',event_fixed,in.time_units));
            end
            
            result_object.line_handles = line_handles;
            
        end
    end
    
    %Add Event or History to data object ----------------------------------
    methods
        function newEventFromEvent(objs,old_name,new_name)
           %The example use case is when a file has been marked with a
           %particular comment
           %
           %    We want to find all strings that match some value
           %    then extract those times (and values?) and move those 
           %    to a new event
           %
           %    TODO: What do we need from the user ?????
        end
        function events = getEvent(objs,name)
            %x Gets a specific event name for all objects
            %
            %    events = getEvent(objs,name)
            %
            %    Since events are nested within the event holder object
            %    'event_info' getting an event object for multiple objects
            %    requires a loop. This method removes the need for that
            %    loop.
            %
            %    Examples:
            %    ---------
            %    ev = p.getEvent('qp_start')
            %    qp_start_times = [ev.times]
            
            temp_ca = cell(1,length(objs));
            
            for iObj = 1:length(objs)
                %TODO: add try/catch that makes missing event clearer
                temp_ca{iObj} = objs(iObj).event_info.(name);
            end
            
            events = [temp_ca{:}];
        end
        function addEventElements(obj,event_elements)
            %x Adds event elements to the object. See 'devents' property
            %
            %   Inputs:
            %   -------
            %   event_elements : See sci.time_series.events_holder.addEvents
            %
            %   See Also:
            %   sci.time_series.discrete_events
            %   sci.time_series.epochs
            %   sci.time_series.events_holder
            %   sci.time_series.events_holder.addEvents
            
            obj.event_info.addEvents(event_elements);
        end
        function addHistoryElements(obj,history_elements)
            %x Adds history elements (processing summaries) to the object
            %
            %   addHistoryElements(obj,history_elements)
            %
            %   Inputs:
            %   -------
            %   history_elements : cell or string
            %       See definition of the 'history' property in this class
            %
            if iscell(history_elements)
                if size(history_elements,2) > 1
                    history_elements = history_elements';
                end
            elseif ischar(history_elements)
                history_elements = {history_elements};
            else
                error('Invalid history element type')
            end
            
            obj.history = [obj.history; history_elements];
        end
    end
    
    %Time related manipulations -------------------------------------------
    methods
        %getDataSubset - in a separate file
% % % %         function varargout = scaleTime(objs)
% % % %            %x 
% % % %            %    
% % % %            %    This function was originally written to handle cases in
% % % %            %    which
% % % %            %
% % % %            %    - we have 2 issues, changing the sampling rate and scaling
% % % %         end

        function varargout = zeroTimeByEvent(objs,event_name_or_time_array,varargin)
            %x Redefines time such that the time of event is now at time zero.
            %
            %   Calling Forms:
            %   --------------
            %   objs.zeroTimeByEvent(event_name)
            %
            %   objs.zeroTimeByEvent(event_times)
            %
            %   Inputs:
            %   -------
            %    event_name :
            %        This refers to one of the internal events in the object.
            %    event_times :
            %        A single event time should be provided for each object
            %
            %   Examples:
            %   ---------
            %   pres.zeroTimeByEvent('start_pump')
            %
            %   See Also:
            %   sci.time_series.data.getDataAlignedToEvent()
            %   sci.time_series.data.getDataSubset()
            
            in.same_absolute_time = true; %NYI - if false
            %then we don't redefine absolute time
            in = sl.in.processVarargin(in,varargin);
            
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            
            n_objects = length(temp);
            if isnumeric(event_name_or_time_array)
                event_times = event_name_or_time_array;
                %TODO: Make this more accurate
                history_entry = {sprintf('Timeline zeroed by some time')};
            else
                %TODO: This should be easier to do...
                event_name = event_name_or_time_array;
                event_times = zeros(1,n_objects);
                history_entry = {sprintf('Timeline zeroed by %s',event_name)};
                for iObj = 1:n_objects
                    temp_event_obj = temp(iObj).event_info.(event_name);
                    if length(temp_event_obj.times) ~= 1
                        error('Each event must have only 1 time value ..., for now')
                    end
                    event_times(iObj) = temp_event_obj.times;
                end
            end
            
            
            
            %TODO: Make this a method in the time object - shift time
            for iObj = 1:n_objects
                %Adjust time start_offset
                cur_obj = temp(iObj);
                cur_obj.time.start_offset   = cur_obj.time.start_offset - event_times(iObj);
                
                cur_obj.addHistoryElements(history_entry);
                
                %TODO: Do I want this ...????
                cur_obj.time.start_datetime = cur_obj.time.start_datetime;
                %Adjust event times
                all_events = temp(iObj).event_info;
                fn = fieldnames(all_events);
                for iField = 1:length(fn)
                    %all_events is just a structure
                    cur_event = all_events.(fn{iField});
                    cur_event.shiftStartTime(event_times(iObj));
                end
            end
            
            if nargout
                varargout{1} = temp;
            end
            
        end
        %         function sample_number = timeToSample(obj)
        %             error('Not yet implemented')
        %         end
        function varargout = removeTimeGapsBetweenObjects(objs)
            %x Removes any time gaps between objects (for plotting)
            %
            %   removeTimeGapsBetweenObjects(objs)
            %
            %   Example:
            %   --------
            %   p.removeTimeGapsBetweenObjects()
            %   plot(p)
            
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            
            last_time = 0; %Should this be the first object ?????
            for iObj = 1:length(objs)
                cur_obj = temp(iObj);
                cur_obj.time.start_offset = last_time;
                cur_obj.time.start_datetime = 0;
                last_time = cur_obj.time.end_time;
            end
            
            if nargout
                varargout{1} = temp;
            end
        end
    end
    
    %Misc. Methods ----------------------------------------------------
    methods
        function [data,time] = getRawDataAndTime(obj)
            %x Returns the raw data and time
            %
            %   [data,time] = getRawDataAndTime(obj)
            %
            %   Outputs:
            %   --------
            %   data : array
            %   time : array
            %
            %   Examples:
            %   ---------
            %   [p_data,p_time] = p.getRawDataAndTime
            data = obj.d;
            time = obj.time.getTimeArray();
        end       
        function varargout = dif2(objs)
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            temp.runFunctionsOnData({@h__dif2});
            if nargout
                varargout{1} = temp;
            end
        end       
    end 
    
    %Data changing --------------------------------------------------------
    methods
        function varargout = minSubtract(objs,varargin)
            %x Subtracts the min of the data from the data
            %
            %   Performs the operation:
            %   B = A - min(A)
            %
            %   
            in.dim = [];
            in = sl.in.processVarargin(in,varargin);
            
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            
            if isempty(in.dim)
                for iObj = 1:length(objs)
                    cur_obj   = temp(iObj);
                    cur_obj.d = bsxfun(@minus,cur_obj.d,min(cur_obj.d));
                end
            else
                dim_use = in.dim;
                for iObj = 1:length(objs)
                    cur_obj   = temp(iObj);
                    cur_obj.d = bsxfun(@minus,cur_obj.d,min(cur_obj.d,dim_use));
                end
            end
            
            if nargout
                varargout{1} = temp;
            end 
        end
        function varargout = meanSubtract(objs,varargin)
            %x Subtracts the mean of the data from the data
            %
            %   Performs the operation:
            %   B = A - mean(A)
            %
            %   Note, part of me would rather have a mean()
            %   function, but this removes time, which I would need to
            %   handle. Also, if mean(A) is not a scalar, then I would
            %   also need to build in bsxfun support.
            %
            %
            %   Optional Inputs:
            %   ----------------
            %   dim : scalar (default, [])
            %       Dimension over which to calculate the mean. If empty,
            %       the first non-singleton is used.
            
            in.dim = [];
            in = sl.in.processVarargin(in,varargin);
            
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            
            if isempty(in.dim)
                for iObj = 1:length(objs)
                    cur_obj   = temp(iObj);
                    cur_obj.d = bsxfun(@minus,cur_obj.d,mean(cur_obj.d));
                end
            else
                dim_use = in.dim;
                for iObj = 1:length(objs)
                    cur_obj   = temp(iObj);
                    cur_obj.d = bsxfun(@minus,cur_obj.d,mean(cur_obj.d,dim_use));
                end
            end
            
            if nargout
                varargout{1} = temp;
            end
        end
        function varargout = filter(objs,filters,varargin)
            %x Filter the data using filters specified as inputs
            %
            %   This function can be used to filter the data. It is meant
            %   to remove some of the details that are normally associated
            %   with filtering the data, like worrying about the sampling
            %   frequency.
            %
            %   i.e. filter from 10 to 20 Hz NOT 10*2/fs to 20*2/fs
            %
            %
            %   Filter List:
            %   -----------------------------------------------
            %   in sci.time_series.filter package
            %   (NOTE: This is likely not complete/out of date)
            %
            %   - butter   - i.e. sci.time_series.filter.butter
            %   - ellip     sci.time_series.filter.ellip - etc
            %   - max
            %   - min
            %   - smoothing
            %
            %   Inputs:
            %   -------
            %   filters : filter object or cell array of filter objects
            %
            %   Optional Inputs:
            %   ----------------
            %   subtract_filter_result : logical (Default false)
            %       If true, the returned signal is the result of taking
            %       the filtered signal and subtracting it from the
            %       original signal.
            %
            %           i.e. rseult_data = data - filter(data)
            %
            %   Examples:
            %   ---------
            %   1)
            %
            %       notch_filter = sci.time_series.filter.butter(2,[55 65],'stop');
            %       eus_data_f   = filter(eus_data,notch_filter);
            %
            %   2)
            %
            %       hp_filter = sci.time_series.filter.butter(2,100,'high');
            %       filtered_pres_data = filter(pres_data,notch_filter);
            %
            %   See Also:
            %   sci.time_series.data_filterer
            
            if ~iscell(filters)
                filters = {filters};
            end
            
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            
            in.subtract_filter_result = false;
            in = sl.in.processVarargin(in,varargin);
            
            df = sci.time_series.data_filterer('filters',filters);
            df.filter(temp,'subtract_filter_result',in.subtract_filter_result);
            
            %TODO: Add on history of filtering ...
            %Filters need to have this method (getSummaryString) added, see
            %   sci.time_series.filter.smoothing for an example
            
            for iObj = 1:length(objs)
                cur_obj = temp(iObj);
                try %#ok<TRYNC>
                    filter_summaries = cellfun(@(x) getSummaryString(x,cur_obj.time.fs),filters,'un',0);
                    
                    cur_obj.addHistoryElements(filter_summaries);
                end
                
            end
            
            if nargout
                varargout{1} = temp;
            end
        end
        function decimated_data = decimateData(objs,bin_width,varargin)
            %x Resample time series after some smoothing function is applied
            %
            %   decimated_data = decimateData(objs,bin_width)
            %
            %   Currently decimation is done after taking the mean absolute
            %   value.
            %
            %   Inputs:
            %   -------
            %   bin_width : scalar (s)
            %       The width of each bin for decimation
            %
            %   Example:
            %   --------
            %   p_dec = p.decimateData(1);
            
            in.approach = 'mean_absolute'; %no options yet besides this
            in.allow_last_bin = false; %NYI
            %in = sl.in.processVarargin(in,varargin);
            
            
            n_objs         = length(objs);
            decimated_data = cell(1,n_objs);
            
            history_string = sprintf('Data decimated via .decimateData() with %gs width',bin_width);
            
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
                
                switch in.approach
                    case 'mean_absolute'
                        for iBin = 1:n_bins
                            temp_data = cur_data(start_Is(iBin):end_Is(iBin),:,:);
                            %NOTE: Eventually we might want additional methods
                            new_data(iBin,:,:) = mean(abs(temp_data),1);
                        end
                    otherwise
                        error('unexpeced decimation approach')
                end
                
                new_time_object = copy(cur_obj.time);
                
                new_time_object.n_samples = n_bins;
                new_time_object.dt = dt_exact;
                new_time_object.shiftStartTime(dt_exact/2);
                
                new_data_obj = h__createNewDataFromOld(cur_obj,new_data,new_time_object);
                
                new_data_obj.addHistoryElements(history_string);
                
                decimated_data{iObj} = new_data_obj;
            end
            
            decimated_data = [decimated_data{:}];
            
        end
        function changeUnits(objs,new_units)
            %x Given the new units, scales/converts the data accordingly
            %
            %
            %   I am planning on remo
            %
            %   HIGHLY EXPERIMENTAL
            %   Relies on sci.units.getConversionFunction which is woefully
            %   incomplete and is basically only hardcoded for the values
            %   I'm using.
            %
            %   Inputs:
            %   -------
            %   new_units : string
            %
            %   Example:
            %   --------
            %   raw_data = sci.time_series.data(ones(100,1),1,'units','V')
            %   plot(raw_data)
            %   raw_data.changeUnits('mV')
            %   hold all
            %   plot(raw_data) %This will be 1000x larger
            %
            %
            %
            %
            %   See Also:
            %   sci.units.getConversionFunction
            
            %TODO: We could allow new_units to be a cellstr as well
            
            if ~all(strcmp({objs.units},objs(1).units))
                error('Not all units are the same as the first object')
            end
            
            cur_units = objs(1).units;
            
            if ~strcmp(cur_units,new_units)
                fh = sci.units.getConversionFunction(cur_units,new_units);
                
                for iObj = 1:length(objs)
                    cur_obj = objs(iObj);
                    
                    cur_obj.d     = fh(cur_obj.d);
                    cur_obj.units = new_units;
                    
                    history_str   = sprintf('Units changed from %s to %s, data scaled appropriately',cur_units,new_units);
                    cur_obj.addHistoryElements({history_str})
                end
            end
        end
    end
    
    %Math functions --------------------------------- e.g. abs, minus
    %
    %   These methods are slowly being created as they are needed.
    %
    %   NOTE: These methods are currently hidden so that they don't
    %   fill up the tab complete pane. It should be assumed that these
    %   functions exist.
    methods (Hidden)
        function runFunctionsOnData(objs,functions)
            %x  Executes a a set of functions on the object
            %
            %   This is really a helper function for some of the basic
            %   math functions.
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
    end
    %In place manipulations
    methods (Hidden)
        %Possibles to add:
        %- ceil
        %- floor
        %- round
        %- sqrt
        %- diff
        %- exp
        %- log
        %- log10
        
        function out_objs = add(A,B)
            %x Performs the addition operation
            %
            %   Calling Forms:
            %   --------------
            %   out_objs = add(A,B)
            %
            %   out_objs = A + B;
            %
            %   Note, this function currently always makes a copy. The copy
            %   operation in the dual object case is a bit ambiguous, as
            %   both object have history and names. Currently the first
            %   objects properties are copied in this case.
            %
            %
            
            if isobject(A) && isobject(B)
                out_objs = copy(A);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A(iObj).d + B(iObj).d;
                end
            elseif isobject(A)
                out_objs = copy(A);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A(iObj).d + B;
                end
            else
                out_objs = copy(B);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A + B(iObj).d;
                end
            end
        end
        function out_objs = minus(A,B)
            %x Performs the minus operation
            %
            %   out_objs = minus(A,B)
            %
            %   out_objs = A - B;
            %
            %   Note, this function currently always makes a copy. The copy
            %   operation in the dual object case is a bit ambiguous, as
            %   both object have history and names. Currently the first
            %   objects properties are copied in this case.
            %
            %
            
            %NOTE: We are supporting either a 1:1 length match for objects
            %or the case where A or B is an object or array of objects, and
            %the other input is an array.
            
            if isobject(A) && isobject(B)
                out_objs = copy(A);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A(iObj).d - B(iObj).d;
                end
            elseif isobject(A)
                out_objs = copy(A);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A(iObj).d - B;
                end
            else
                out_objs = copy(B);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A - B(iObj).d;
                end
            end
            
        end
        function varargout = abs(objs)
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            temp.runFunctionsOnData({@abs});
            if nargout
                varargout{1} = temp;
            end
        end
        
        function out_objs = mean(objs,dim,varargin)
           if nargin == 1 || isempty(dim)
               dim = 1;
           end
            n_objs = length(objs);
            output = cell(1,n_objs);
            
           for iObj = 1:length(objs)
               output{iObj} = mean(objs(iObj).d,dim);
           end
           
           out_objs = [output{:}];

        end
        function varargout = mrdivide(objs,B)
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            temp.runFunctionsOnData({@(x)mrdivide(x,B)});
            if nargout
                varargout{1} = temp;
            end
        end
        function varargout = power(objs,B)
            %x Raises the input to a given power
            %
            %   Performs:
            %   new_objs = objs^B
            %
            %
            
            if nargout
                temp = copy(objs);
            else
                temp = objs;
            end
            temp.runFunctionsOnData({@(x)power(x,B)});
            if nargout
                varargout{1} = temp;
            end
        end
    end
    %Data reduction basic math methods -------------- e.g. max,min
    methods (Hidden)
        %TODO: Describe some of the concerns with these methods
        %   i.e. returning scalars vs objs depending on dimension
        %
        %
        %   The design of these methods might change ...
        function output = max(objs,varargin)
            
            in.dim = 1;
            in.un = true;
            in = sl.in.processVarargin(in,varargin);
            
            if in.dim ~= 1
                error('Only dim=1 is currently supported')
            end
            
            n_objs = length(objs);
            temp = cell(1,n_objs);
            for iObj = 1:n_objs
                temp{iObj} = max(objs(iObj).d,[],in.dim);
            end
            
            if ~in.un
                output = temp;
            else
                if any(cellfun(@numel,temp) ~= 1)
                    error('One of the objects has more than 1 channel or rep, "''un'',0" required for the input')
                end
                output = [temp{:}];
            end
            
        end
        function output = min(objs,varargin)
            
            in.dim = 1;
            in.un = true;
            in = sl.in.processVarargin(in,varargin);
            
            if in.dim ~= 1
                error('Only dim=1 is currently supported')
            end
            
            n_objs = length(objs);
            temp = cell(1,n_objs);
            for iObj = 1:n_objs
                temp{iObj} = min(objs(iObj).d,[],in.dim);
            end
            
            if ~in.un
                output = temp;
            else
                if any(cellfun(@numel,temp) ~= 1)
                    error('One of the objects has more than 1 channel or rep, "''un'',0" required for the input')
                end
                output = [temp{:}];
            end
        end
        function output = sum(objs,varargin)
            
            in.dim = 1;
            in.un = true;
            in = sl.in.processVarargin(in,varargin);
            
            if in.dim ~= 1
                error('Only dim=1 is currently supported')
            end
            
            n_objs = length(objs);
            temp = cell(1,n_objs);
            for iObj = 1:n_objs
                temp{iObj} = sum(objs(iObj).d,in.dim);
            end
            
            if ~in.un
                output = temp;
            else
                if any(cellfun(@numel,temp) ~= 1)
                    error('One of the objects has more than 1 channel or rep, "''un'',0" required for the input')
                end
                output = [temp{:}];
            end
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

events = obj.event_info;

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

function fd = h__dif2(f)
%dif2  Computes two point diference estimate of velocity.
%
%  DIFFERENCE = dif2(SIGNAL)
%
%  Computes the difference at a point as being the average of slopes on
%  either side of the point, returns a vector DIFFERENCE, the same size as
%  in the input SIGNAL
%
%  If SIGNAL is a matrix it takes the difference of the rows in each column
%
%  To convert the output to dif2 to the proper units multiply by fs
%
% tags: math, calculus, slope
[r c] = size(f);

%May 04, 2010 : JAH, modified to keep dimensions of single vector

if isempty(f)
    fd = f;
    return
end

if r == 1 && c == 1
    error('Dif2 is undefined for a single point')
elseif r >1 && c > 1
    fd=zeros(r,c);
    fd(1,:)=f(2,:)-f(1,:);
    fd(r,:)=f(r,:)-f(r-1,:);
    df=diff(f);
    fd(2:r-1,:)=.5*(df(2:r-1,:)+df(1:r-2,:));
else %The single vector case
    fd=zeros(r,c);
    
    fd(1)=f(2)-f(1);
    
    fd(end)=f(end)-f(end-1);
    
    df = diff(f);
    
    %     fd(1) = df(1);
    %     fd(end) df(end);
    %
    
    fd(2:end-1)= 0.5*(df(2:end)+df(1:end-1));
end
end

