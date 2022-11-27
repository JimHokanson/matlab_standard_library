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
        name %string
        %   I think this is just for the user ...
        
        start_times
        stop_times
        durations
        values
    end
    
    methods (Static)
      	function obj = fromStruct(s)
            obj = sci.time_series.epochs(s.prop_name,s.start_times,...
                s.stop_times,'name',s.name,'values',s.values);
        end 
    end
    
    methods
        function obj = epochs(prop_name,start_times,stop_times,varargin)
            %
            %   obj = sci.time_series.epochs(prop_name,start_times,stop_times,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   name : string
            %       Unclear how this is used other than internally
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

        function s_obj = export(objs)
            s_obj = sl.obj.toStruct(objs);
        end
        function shiftStartTime(objs,time_to_subtract)
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                %time_to_subtract = h__unscaleTime(cur_obj,time_to_subtract);
                cur_obj.start_times = cur_obj.start_times - time_to_subtract;
                cur_obj.stop_times  = cur_obj.stop_times - time_to_subtract;
            end
        end
        function new_obj = copy(old_obj,varargin)
            
            in.time_shift = 0;
            in = sl.in.processVarargin(in,varargin);
            
            new_obj = sci.time_series.epochs(old_obj.prop_name,old_obj.start_times-in.time_shift,old_obj.stop_times-in.time_shift);
            new_obj.name = old_obj.name;
            new_obj.values = old_obj.values;
        end
        function plotHorizontalLines(obj,varargin)
            %
            %TODO: Clean this up ...
            
            Y_PCT_POS = 0.05;
            
            if ~isempty(obj.start_times)
                x = [obj.start_times(:) obj.stop_times];
                
            
                line_handles = sl.plot.type.horizontalLines(Y_PCT_POS,'y_as_pct',true,'x_values',x,'color','k');
            end

        end
    end
    
end

