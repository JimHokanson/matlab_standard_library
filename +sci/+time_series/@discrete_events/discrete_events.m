classdef discrete_events < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.discrete_events
    %
    %   This is meant to hold discrete events that are associated with a
    %   time series. It can be used for example to:
    %       - add comments to a time series
    %       - associate other important triggers with a channel
    %
    %   See Also:
    %   sci.time_series.time
    %   sci.time_series.data
    %   sci.time_series.data.getDataSubset
    %   sci.time_series.events_holder
    
    properties
       prop_name %string
       %    This should be a unique identifier and must also be a safe
       %    variable name.
       
       name %string
       %    This can be whatever and is not restricted to the limitations 
       %    of the prop name. The default behavior is to make this the same
       %    as the prop_name if it is not specified.
       
       times %array of times
       output_units = 's'
       values %anything
       msgs %cellstr
       %    Any associated strings with each event. This can be empty. This
       %    was originally designed for comments from raw data files where
       %    each comment has a time and a string.
    end
    
    methods 
        function value = get.times(obj)
           value = h__getTimeScaled(obj,obj.times); 
        end
    end
    
    methods
        function obj = discrete_events(prop_name,times,varargin)
            %
            %   obj = sci.time_series.discrete_events(prop_name,times,varargin)
            %
            %
            
           in.name   = '';
           in.values = [];
           in.msgs   = [];
           in = sl.in.processVarargin(in,varargin);
           
           if isempty(in.name)
               in.name = prop_name;
           end
           
           obj.prop_name  = prop_name;
           obj.name  = in.name;
           obj.times = times;
           
           obj.values = in.values;
           obj.msgs   = in.msgs;
        end
        function new_obj = copy(old_obj)
           %TODO: Implement this ...
           new_obj = old_obj;
        end
        function prettyPrint(obj)
            %
            %   prettyPrint(obj)
            %
            %
            %
            %   TODO: Align columns ...
            
%             40: 15024, 40, void
%             41: 15032.6, 41, stop pump
%             42: 15556.9, 42, start pump
           
            fprintf('Event: %s\n',obj.name);
            msgs_local = obj.msgs;
            if isempty(msgs_local)
               msgs_local = cell(1,length(obj.times)); 
               msgs_local(:) = {''};
            end
            
            values_local = obj.values;
            if isempty(values_local)
               values_local = cell(1,length(obj.times));
               values_local(:) = {''};
            else
               values_local = arrayfun(@num2str,values_local,'un',0);
            end
            
            times_local = arrayfun(@(x)num2str(x,'%g'),obj.times,'un',0);
            
            fprintf('format -----\n');
            fprintf('Index: time, value, msg\n')
            fprintf('---------------------------:\n')
            for iEvent = 1:length(obj.times)
               %ID, time, value, msg
               fprintf('%d: %s, %s, %s\n',iEvent,times_local{iEvent},values_local{iEvent},msgs_local{iEvent})
            end
   
        end
        function plot(obj,varargin)
            %
            %
            %   Optional Inputs:
            %   ----------------
            %   I : array (default 'all')
            %       Event indices to plot.
            %   axes : array (default calls gca)
            %       Axes to plot into
            
           keyboard 
           
           in.I = 'all';
           in.axes = 'gca';
           in = sl.in.processVarargin(in,varargin);
           
           if ischar(in.axes)
               in.axes = gca;
           end
           
           if ischar(in.I)
               in.I = 1:length(obj.times);
           end
           
           line_handles = sl.plot.type.verticalLines(obj.times(in.I),'Color','k');
           
           %Plot style:
           %-----------
           %
           
        end
        function shiftStartTime(objs,time_to_subtract)
            for iObj = 1:length(objs)
               cur_obj = objs(iObj);
               time_to_subtract = h__unscaleTime(cur_obj,time_to_subtract);
               cur_obj.times = cur_obj.times - time_to_subtract;
            end
        end
        function s_obj = export(objs)
           s_obj = sl.obj.toStruct(objs);
        end
        function changeUnits(objs,new_value)
           for iObj = 1:length(objs)
              cur_obj = objs(iObj);
              cur_obj.output_units = new_value;
           end
        end
    end
    
end



%TODO: Document these functions
%This should all be moved to sci.units ...
function times_scaled = h__getTimeScaled(obj,times)
scale_factor = h__getTimeScaleFactor(obj.output_units,true);
if scale_factor == 1
    times_scaled = times;
else
    times_scaled = times*scale_factor;
end
end

function unscaled_times = h__unscaleTime(obj,times)
scale_factor = h__getTimeScaleFactor(obj.output_units,false);
if scale_factor == 1
    unscaled_times = times;
else
    unscaled_times = times*scale_factor;
end
end

function scale_factor = h__getTimeScaleFactor(unit_name,for_output)
switch unit_name
    case {'s','seconds'}
        scale_factor = 1;
    case {'ms','milliseconds'}
        scale_factor = 1000;
    case {'min','minutes'}
        scale_factor = 1/60;
    case {'h','hours'}
        scale_factor = 1/3600;
    otherwise
        error('Unrecognized time unit: %s',unit_name)
end
if ~for_output
    scale_factor = 1/scale_factor;
end
end
