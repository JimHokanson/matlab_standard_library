classdef events_holder < dynamicprops
    %
    %   Class:
    %   sci.time_series.events_holder
    %
    %   This class holds all of the events for a particular instance of
    %   sci.time_series.data
    %
    %   sci.time_series.data.event_info => instance of this class
    %
    %   As a dynamicprops class, the event objects are added dynamically as
    %   properties to the class instances.
    %
    %   This class holds:
    %   sci.time_series.discrete_events
    %   sci.time_series.epochs
    %
    %
    %   See Also:
    %   ---------
    %   sci.time_series.data
    %   sci.time_series.time
    %   sci.time_series.discrete_events
    %   sci.time_series.epochs
    
    properties
        p__all_event_names = {}; %cellstr
        %List of all events
        
        p__time_obj %time object for parent data
        %This is needed for properly zeroing events
        %We can't store this in the axes because it is specific to a
        %channel
        %
        %We could store it in the line but then we would need a way of
        %associating a plotted line with the relevant events ...
        %
        %=> unique id??
        
    end
    
    methods
        function obj = events_holder(time)
            obj.p__time_obj = time;
        end
        function addEvents(obj,event_elements)
            %x Add multiple events to the class
            %
            %   Calling Forms
            %   -------------
            %   addEvents(obj,event_holder)
            %
            %   addEvents(obj,events_cell)
            %
            %   Inputs
            %   ------
            %   events_holder : sci.time_series.events_holder
            %   events_cell : {sci.time_series.discrete_events}
            %
            %   TODO: Finish documentation
            
            if isa(event_elements,'sci.time_series.events_holder')
                old_obj = event_elements;
                event_names = old_obj.p__all_event_names;
                if isempty(event_names)
                    event_elements = {};
                else
                    event_elements = cellfun(@(x) old_obj.(x),event_names,'un',0);
                end
            elseif ~iscell(event_elements)
                event_elements = num2cell(event_elements);
            end
            
            for iElement = 1:length(event_elements)
                cur_element = event_elements{iElement};
                h__addSingleEvent(obj,cur_element);
            end
        end
        function value = fieldnames(obj)
            %x Returns list of all events
            %
            %   Why don't we just return p__all_event_names ???
            
            %We want to know the events, not all the properties ...
            value = builtin('fieldnames',obj);
            value(strcmp(value,'p__all_event_names')) = [];
            value(strcmp(value,'p__time_obj')) = [];
        end
        function shiftTimes(obj,varargin)
            %
            %   shiftTimes(obj,time_to_subtract)
            %
            %   shiftTimes(obj,old_time_obj,new_time_obj)
            
            if isnumeric(varargin(1))
                time_to_subtract = varargin(1);
            else
                old_time = varargin{1};
                new_time = varargin{2};
                time_to_subtract = old_time.start_offset - new_time.start_offset;
            end
            fn = fieldnames(obj);
            for iField = 1:length(fn)
                cur_name = fn{iField};
                obj.(cur_name).shiftStartTime(time_to_subtract);
                %h__addSingleEvent(new_obj,copy(old_obj.(cur_name),'time_shift',in.time_shift))
            end
        end
        function new_obj = copy(old_obj,new_time_obj,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   time_shift :
            %
            %   Improvements
            %   ------------
            %   1) Allow copying without requiring a new time instance
            
            in.time_shift = 0;
            in = sl.in.processVarargin(in,varargin);
            
            new_obj = sci.time_series.events_holder(new_time_obj);
            fn = fieldnames(old_obj);
            for iField = 1:length(fn)
                cur_name = fn{iField};
                %sci.time_series.discrete_events>copy
                %sci.time_series.epochs>copy
                new_event_or_epoch = copy(old_obj.(cur_name),'time_shift',in.time_shift);
                h__addSingleEvent(new_obj,new_event_or_epoch);
            end
        end
        function objs = getEpochs(obj)
            %x Get all epoch objects
            %
            %   objs = getEpochs(obj)
            %
            
            all_events = cellfun(@(x) obj.(x), obj.p__all_event_names, 'un', 0);
            names = cellfun(@(x) class(x), all_events, 'UniformOutput', false);
            t = cellfun(@(x) strfind(x,'epochs'), names, 'UniformOutput', false);
            t2 = cellfun(@(x) ~isempty(x), t);
            
            objs = all_events(t2);
        end
        function epoch_names = getEpochNames(obj)
            %x Get the names of all epoch objects
            %
            %   epoch_names = getEpochNames(obj)
            
            all_events = cellfun(@(x) obj.(x), obj.p__all_event_names, 'un', 0);
            all_names = cellfun(@(x) class(x), all_events, 'UniformOutput', false);
            t = cellfun(@(x) strfind(x,'epochs'), all_names, 'UniformOutput', false);
            t2 = cellfun(@(x) ~isempty(x), t);
            epoch_names = all_names(t2);
        end
        function plotEvent(obj,event_name,varargin)
            %x plot an event as vertical lines
            %
            %   sci.time_series.events_holder.plotEvent(obj,event_name,varargin)
            %
            %   Optional Inputs
            %   --------------------------------
            %   Details in: sci.time_series.discrete_events.plot
            %   TODO: List name here
            %
            %   See Also
            %   --------
            %   sci.time_series.discrete_events.plot
            
            try
                event = obj.(event_name);
            catch ME
                error('Requested event: %s does not exist',event_name)
            end
            %TODO: Verify that this is an event and not an epoch ...
            plot(event,'zero_time_value',obj.p__time_obj.start_time,varargin{:});
        end
        function plotEpochDuration(obj)
            error('Not yet implemented')
        end
    end
    
end
function h__addSingleEvent(obj,event_element)
    prop_name = event_element.prop_name;
    addprop(obj,prop_name);
    obj.(prop_name) = event_element;
    obj.p__all_event_names = [obj.p__all_event_names, prop_name];
end

