classdef time_events < handle
    %
    %   Class:
    %   sci.time_series.time_events
    %
    %   This is meant to hold discrete events that are associated with a
    %   time series. It can be used for example to:
    %   - add comments to a time series
    %   - associate other important triggers with a channel
    %
    %   See Also:
    %   sci.time_series.data
    %
    %   TODO: Handle support for time units
    
    
    properties
       name %This should be a unique identifier
       times %in seconds, this needs to be fixed so that it matches
       %the time object for plotting ...
       values
       msgs
    end
    
    methods
        function obj = time_events(name,times,varargin)
           in.values = [];
           in.msgs   = [];
           in = sl.in.processVarargin(in,varargin);
           
           obj.name  = name;
           obj.times = times;
           
           obj.values = in.values;
           obj.msgs   = in.msgs;
        end
        function new_obj = copy(old_obj)
           %TODO: Implement this ...
           new_obj = old_obj;
        end
        function shiftStartTime(objs,time_to_subtract)
            for iObj = 1:length(objs)
               cur_obj = objs(iObj);
               cur_obj.times = cur_obj.times - time_to_subtract;
            end
        end
    end
    
end

