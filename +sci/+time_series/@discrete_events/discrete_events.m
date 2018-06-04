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
    %   sci.time_series.events_holder
    %   sci.time_series.epochs
    
    properties
        prop_name %string
        %    This should be a unique identifier and must also be a safe
        %    variable name.
        
        name %string
        %    This can be whatever and is not restricted to the limitations
        %    of the prop name. The default behavior is to make this the same
        %    as the prop_name if it is not specified.
        
        times %array of times
        
%         output_units = 's'
        values %anything
        %numeric is preferable but any sort of value could be associated
        
        msgs %cellstr
        %    Any associated strings with each event. This can be empty. This
        %    was originally designed for comments from raw data files where
        %    each comment has a time and a string.
    end
    
    methods
%         function value = get.times(obj)
%             value = h__getTimeScaled(obj,obj.times);
%         end
    end
    
    methods
        function obj = discrete_events(prop_name,times,varargin)
            %
            %   obj = sci.time_series.discrete_events(prop_name,times,varargin)
            %
            %   See property definitions for definitions of inputs and
            %   optional inputs.
            %
            %   Inputs:
            %   -------
            %   prop_name :
            %   times :
            %   
            %   Outputs:
            %   --------
            %   name :
            %   values :
            %   msgs : 
            %
            %   Examples
            %   -----------------------------------------------------------
            %   comment_events =
            %   sci.time_series.discrete_events('comments',c.times,'msgs',c.strings)
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
        function new_obj = copy(old_obj,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   time_shift : scalar (default 0)
            %       Value is subtracted from the times values
            %   
            
            in.time_shift = 0;
            in = sl.in.processVarargin(in,varargin);
            
            new_obj = sci.time_series.discrete_events(old_obj.prop_name,old_obj.times - in.time_shift);
            
            %TODO: This should be a generic method via sl
            fn = fieldnames(old_obj);
            for iField = 1:length(fn)
                cur_name = fn{iField};
                new_obj.(cur_name) = old_obj.(cur_name);
            end
        end
        function prettyPrint(obj)
            %
            %   prettyPrint(obj)
            %
            %   Prints the object in a nice way
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
                values_local = h__valueToString(obj.values);
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
        function h = plot(obj,varargin)
            %x  Plot vertical lines indicating event with text and/or values
            %
            %   h = plot(obj,varargin)
            %
            %   Outputs:
            %   --------
            %   h : {line_handles}
            %       A cell array that contains arrays of line handles, 1
            %       for each input axes
            %
            %   Optional Inputs:
            %   ----------------
            %   I : array (default 'all')
            %       Event indices to plot.
            %   text_mask_fh : function handle (default '')
            %       If present, the 
            %       
            %   axes : array (default calls gca)
            %       Axes to plot into.
            %   show_msgs : logical (default true)
            %   show_values : logical (default true)
            %   text_options : cell (default {})
            %       These are the options that get passed into the text()
            %       command.
            %   events_in_extents_only : logical (default true)
            %       Events that are outside the extents of the axes will
            %       not be plotted
            %   
            %
            %   Improvements:
            %   -------------
            %   1) Provide an option for adding text on the last axes only
            %
            %   Additional optional inputs can be found in:
            %       sl.plot.type.verticalLines
            %
            %   See Also:
            %   ---------
            %   text()
            %   sl.plot.annotation.addLineLabel
            %   sl.plot.type.verticalLines
           
            in.I = 'all';
            in.text_mask_fh = ''; 
            in.axes = 'gca';
            in.show_msgs = true;
            in.show_values = true;
            in.text_options = {};
            in.events_in_extents_only = true;
            [varargin,line_inputs] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(obj.values)
                in.show_values = false;
            end
            if isempty(obj.msgs)
                in.show_msgs = false;
            end

            line_inputs = sl.in.mergeInputs({'Color','k','LineStyle',':'},line_inputs);
            %TODO: If parent is specified in line_inputs we should throw an
            %error since we are allowing looping over multiple axes via
            %in.axes and passing in parent to the plot function directly
            
            if ischar(in.axes)
                in.axes = gca;
            end
            
            if ischar(in.I) %'all'
                if isempty(in.text_mask_fh)
                    in.I = 1:length(obj.times);
                else
                    in.I = find(in.text_mask_fh(obj.msgs));
                end
            end
            
            h = cell(1,length(in.axes));
            
            if isempty(in.I)
               return 
            end
            
            %Actual Plotting
            %----------------
            
            if in.show_msgs && in.show_values
                values_as_strings = h__valueToString(obj.values(in.I));
                display_strings   = cellfun(@(x,y) [x ' : ' y],values_as_strings,obj.msgs(in.I),'un',0);
            elseif in.show_msgs
                display_strings = obj.msgs(in.I);
            elseif in.show_values
                display_strings = h__valueToString(obj.values(in.I));
            else
                display_strings = {};
            end
            
            
            for iAxes = 1:length(in.axes)
                cur_axes = in.axes(iAxes);
                
                times_for_plotting = obj.times(in.I);
                
                %This is not-obvious ...
                app_data_axes = getappdata(cur_axes);
                if isfield(app_data_axes,'time_series_time')
                   time_obj = app_data_axes.time_series_time;
                   %sci.time_series.time
                   times_for_plotting = h__getTimeScaled(times_for_plotting,time_obj.output_units);
                end
                
                if in.events_in_extents_only
                   xlim = get(cur_axes,'xlim');
                   mask = times_for_plotting < xlim(1) | times_for_plotting > xlim(2);
                   times_for_plotting(mask) = [];
                   display_strings(mask) = [];
                end
                
                if isempty(times_for_plotting)
                   continue 
                end
                
                h{iAxes} = sl.plot.type.verticalLines(times_for_plotting,'Parent',cur_axes,line_inputs{:});
                
                if ~isempty(display_strings)
                   cur_h_set = h{iAxes};
                   for iH = 1:length(cur_h_set)
                       cur_h = cur_h_set(iH);
                       
                       temp_x = get(cur_h,'XData');
                       temp_y = get(cur_h,'YData');
                       
                      text(temp_x(1),temp_y(1),display_strings{iH},...
                          'rotation',90,'HorizontalAlignment','left',...
                          'VerticalAlignment','bottom',in.text_options{:},'parent',cur_axes) 
                       
                   end
                    
                   %TODO: I'd like to know why this didn't work with
                   %the pelvic nerve for 140416_C
                   %sl.plot.annotation.addLineLabel(h{iAxes},display_strings,'follow_slope',true,in.text_options{:}); 
                end
            end
            
        end
        function shiftStartTime(objs,time_to_subtract)
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                %time_to_subtract = h__unscaleTime(cur_obj,time_to_subtract);
                cur_obj.times = cur_obj.times - time_to_subtract;
            end
        end
        function s_obj = export(objs)
            s_obj = sl.obj.toStruct(objs);
        end
%         function changeUnits(objs,new_value)
%             for iObj = 1:length(objs)
%                 cur_obj = objs(iObj);
%                 cur_obj.output_units = new_value;
%             end
%         end
    end
    
end

function values_as_strings = h__valueToString(values)
    %NOTE: This assumes a numerical value. Eventually we should
    %write a toString method which works as expected for 
    %numbers or strings but then maybe does a display capture
    %or resorts to the property display method (which is also
    %not yet written)
    values_as_strings = arrayfun(@num2str,values,'un',0);
end

%THESE ARE NOT CURRENTLY BEING USED
%I WANT TO DO THIS VERY DIFFERENTLY
%TODO: Document these functions
%This should all be moved to sci.units ...
function times_scaled = h__getTimeScaled(times,units)
scale_factor = h__getTimeScaleFactor(units,true);
if scale_factor == 1
    times_scaled = times;
else
    times_scaled = times*scale_factor;
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
