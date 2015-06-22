classdef events_holder < dynamicprops
    %
    %   Class:
    %   sci.time_series.events_holder
    %
    %   This class holds all of the events for a particular instance of 
    %   sci.time_series.data
    %
    %   As a dynamicprops class, the event objects are added dynamically as
    %   properties to the class instances.
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
    end
    
    methods
        function addEvents(obj,event_elements)
            %x Add multiple events to the class
            %
            %   Calling Forms:
            %   --------------
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
                %TODO: This might not be valid if the types are different
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
        end
        function shiftTimes(obj,varargin)
            if isnumeric(varargin(1))
                time_shift = varargin(1);
            else
                old_time = varargin{1};
                new_time = varargin{2};
                time_shift = old_time.start_offset - new_time.start_offset;
            end
                fn = fieldnames(obj);
                for iField = 1:length(fn)
                    cur_name = fn{iField};
                    obj.(cur_name).shiftStartTime(time_shift);
                    %h__addSingleEvent(new_obj,copy(old_obj.(cur_name),'time_shift',in.time_shift))
                end
        end
        function new_obj = copy(old_obj,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   time_shift :
            %
            in.time_shift = 0;
            in = sl.in.processVarargin(in,varargin);
            
            new_obj = sci.time_series.events_holder;
            fn = fieldnames(old_obj);
            for iField = 1:length(fn)
                cur_name = fn{iField};
                h__addSingleEvent(new_obj,copy(old_obj.(cur_name),'time_shift',in.time_shift))
            end
        end
    end
    
end
function h__addSingleEvent(obj,event_element)
    prop_name = event_element.prop_name;
    addprop(obj,prop_name);
    obj.(prop_name) = event_element;
    obj.p__all_event_names = [obj.p__all_event_names, prop_name];
end

