classdef epochs < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.epochs
    %
    %   This class was added to support 
    %   
    %   See Also:
    %   sci.time_series.discrete_events
    
    %{
    c = dba.GSK.cmg_expt('140806_C');
    p = c.getData('pres');
    %}
    
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
            %
            %   obj = sci.time_series.epochs(prop_name,start_times,stop_times,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   name :
            %   values : 
            
            in.name = '';
            in.values = [];
            in = sl.in.processVarargin(in,varargin);
            
            obj.prop_name = prop_name;
            
            if isempty(in.name)
                obj.name = prop_name;
            else
                obj.name = in.name;
            end
            
            obj.start_times = start_times;
            obj.stop_times = stop_times;
            
            obj.durations = stop_times - start_times;
            obj.values = in.values;
        end
        function new_obj = copy(old_obj)
           new_obj = sci.time_series.epochs(old_obj.prop_name,old_obj.start_times,old_obj.stop_times);
           new_obj.name = old_obj.name;
           new_obj.values = old_obj.values;
        end
    end
    
end

