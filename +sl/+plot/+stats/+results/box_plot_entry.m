classdef box_plot_entry < handle
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_entry
    
    properties
        h_axes
        h
        h_whisker
        h_upper_whisker %vertical portion of whisker
        h_lower_whisker
        h_upper_adjacent_value %top bar
        h_lower_adjacent_value %bottom bar
        h_box
        h_median
        h_outliers
        data
        box_style
        box_bottom
        box_top
        %- outline (default)
        %- filled (fat line)
        %- box - via this code ...
    end
    
    properties (Dependent)
        x_value
        box_width
    end
    
    methods
        function value = get.x_value(obj)
            value = obj.h__x_value;
        end
        function value = get.box_width(obj)
            value = obj.h__box_width;
        end
        function set.x_value(obj,value)
            %TODO: This logic needs to be implemented ...
            %Move everything ...
        end
        function set.box_width(obj,value)
        end
    end
    
    properties (Hidden)
       h__x_value 
       h__box_width
    end
    
    methods
        function obj = box_plot_entry(h_axes,handles,data)
            %
            %   obj = sl.plot.stats.results.box_plot_entry(handles)
            
            tag_names = get(handles,'Tag');
            
            %Convert double pointers to objects ...
            handles = findobj(handles);
             
            obj.h_axes = h_axes;
            obj.h = handles;
            obj.h_whisker = handles(strcmp(tag_names,'Whisker'));
            obj.h_upper_whisker = handles(strcmp(tag_names,'Upper Whisker'));
            obj.h_lower_whisker = handles(strcmp(tag_names,'Lower Whisker'));
            obj.h_upper_adjacent_value = handles(strcmp(tag_names,'Upper Adjacent Value'));
            obj.h_lower_adjacent_value = handles(strcmp(tag_names,'Lower Adjacent Value'));
            obj.h_box = handles(strcmp(tag_names,'Box'));
            obj.h_median = handles(strcmp(tag_names,'Median'));
            obj.h_outliers = handles(strcmp(tag_names,'Outliers'));
            
            x_data = obj.h_box.XData;
            y_data = obj.h_box.YData;
            switch length(x_data)
                case 5
                    %Outline
                    obj.h__x_value = 0.5*x_data(1)+0.5*x_data(3);
                    obj.box_style = 'outline';
                    obj.h__box_width = x_data(3)-x_data(1);
                    obj.box_top = y_data(2);
                    obj.box_bottom = y_data(1);
                case 2
                    obj.h__x_value = x_data(1);
                    obj.box_style = 'filled';
                    obj.h__box_width = obj.h_box.LineWidth;
                    %Untested ...
                    obj.box_top = y_data(2);
                    obj.box_bottom = y_data(1);
                    %filled
                otherwise
                    error('Unrecognized option')
            end
                        
% %       all styles:  'Box', 'Outliers'
%        traditional: 'Median', 'Upper Whisker', 'Lower Whisker',
%                     'Upper Adjacent Value', 'Lower Adjacent Value', 
%        compact:     'Whisker', 'MedianOuter', 'MedianInner'
%        when 'notch' is 'marker':
%                     'NotchLo', 'NotchHi'
 
            
        end
        function setHandlePropValue(objs,prop,varargin)
           for i = 1:length(objs)
               obj = objs(i);
               set(obj.(prop),varargin{:})
           end
        end
        function changeXLocation(objs,x_locations)
           %JAH: At this point ... 
        end
        function changeBoxType(objs,type)
           %
           %    Inputs
           %    ------
           %    type :
           %        - box
           
           for i = 1:length(objs)
               obj = objs(i);
               switch lower(type)
                   case 'box'
                       %[x y w h]
                       
                       %If we are previously filled this is invalid ...
                       half_width = obj.box_width/2;
                       pos = [obj.x_value - half_width,...
                           obj.box_bottom, ...
                           obj.box_width,...
                           obj.box_top - obj.box_bottom];
                       %position = 
                       h_rect = rectangle(obj.h_axes,'Position',pos);
                       delete(obj.h_box)
                       obj.h_box = h_rect;
                       uistack(obj.h_box,'bottom')
                       %Doesn't work ...
                       %uistack(obj.h_median,'top')
                   otherwise
                       error('Option not recognized')
               end
               obj.box_style = lower(type);
           end
        end
    end
end

