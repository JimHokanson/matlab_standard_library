classdef events_holder < dynamicprops
    %
    %   Class:
    %   sci.time_series.events_holder
    %
    %   See Also:
    %   sci.time_series.data
    %   sci.time_series.discrete_events
    %
    %   Yet to implement:
    %   copy
    %   addEvents
    
    properties
       p__all_event_names = {};
    end
    
    methods
        function addEvents(obj,event_elements)
            
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
           %We want to know the events, not all the properties ...
           value = builtin('fieldnames',obj);
           value(strcmp(value,'p__all_event_names')) = [];
        end
        function new_obj = copy(old_obj)
           new_obj = sci.time_series.events_holder;
            fn = fieldnames(old_obj);
            for iField = 1:length(fn)
                cur_name = fn{iField};
                h__addSingleEvent(new_obj,copy(old_obj.(cur_name))) 
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

