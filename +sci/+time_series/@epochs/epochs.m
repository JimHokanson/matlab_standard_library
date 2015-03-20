classdef epochs < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.epochs
    %
    %   See Also:
    %   sci.time_series.discrete_events
    
    properties
       prop_name %string
       %    This should be a unique identifier and must also be a safe
       %    variable name.
       name
       start_times
       stop_times
       durations
       values
    end
    
    methods
        function obj = epochs(prop_name,start_times,stop_times,varargin)
            in.name = '';
            in = sl.in.processVarargin(in,varargin);
        end
    end
    
end

