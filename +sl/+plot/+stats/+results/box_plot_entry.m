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
        h_upper_extent_bar %top bar
        h_lower_extent_bar %bottom bar
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
        x_center
        box_width
    end
    
    methods
        function value = get.x_center(obj)
            value = obj.h__x_center;
        end
        function value = get.box_width(obj)
            value = obj.h__box_width;
        end
        function set.x_center(obj,value)
            %TODO: This logic needs to be implemented ...
            %Move everything ...
        end
        function set.box_width(obj,value)
        end
    end
    
    properties (Hidden)
        h__x_center
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
            obj.h_upper_extent_bar = handles(strcmp(tag_names,'Upper Adjacent Value'));
            obj.h_lower_extent_bar = handles(strcmp(tag_names,'Lower Adjacent Value'));
            obj.h_box = handles(strcmp(tag_names,'Box'));
            obj.h_median = handles(strcmp(tag_names,'Median'));
            obj.h_outliers = handles(strcmp(tag_names,'Outliers'));
            
            x_data = obj.h_box.XData;
            y_data = obj.h_box.YData;
            switch length(x_data)
                case 5
                    %Outline
                    obj.h__x_center = 0.5*x_data(1)+0.5*x_data(3);
                    obj.box_style = 'outline';
                    obj.h__box_width = x_data(3)-x_data(1);
                    obj.box_top = y_data(2);
                    obj.box_bottom = y_data(1);
                case 2
                    obj.h__x_center = x_data(1);
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
            
            outlier_y_data = obj.h_outliers.YData;
            
          	obj.data = sl.plot.stats.results.box_plot_entry_data(data,...
                outlier_y_data,obj.box_width,obj.x_center);

            
        end
        function renderScatterData(objs,varargin)
            %
            %   See Also
            %   --------
            %   sl.plot.stats.results.box_plot_entry_data.renderScatterData  
            
            for i = 1:length(objs)
                obj = objs(i);
                obj.data.renderScatterData(varargin);
            end 
        end
        function setHandlePropValue(objs,prop,varargin)
            for i = 1:length(objs)
                obj = objs(i);
                set(obj.(prop),varargin{:})
            end
        end
        
        function changeWidth(objs,new_width,varargin)
            %This will change box and other relevant widths
            
            in.scale_extent_bars = true; %NYI
            in.scale_median = true; %NYI => note scaling
            %implies that the median could be at a different scale ...
            in = sl.in.processVarargin(in,varargin);
            
            new_half_width = new_width/2;
            
            %TODO: Allow changing median and box independently (and data)
            
            %TODO: Allow scaling top and bottom bar proportionally
            %to the change in
            
            %TODO: This will need to handle scatter data as well ...
            for i = 1:length(objs)
                obj = objs(i);
                
                scale_factor = new_width/obj.box_width;
                
                %TODO: Make this a function ...
                if strcmp(obj.box_style,'box')
                    obj.h_box.Position = h__scaleFromCenterPosition(obj.h_box.Position,scale_factor);                    
                elseif strcmp(obj.box_style,'outline')
                    error('Unsupported code case')
                else
                    error('Unsupported code case')
                end
                
                if in.scale_median
                obj.h_median.XData = h__scaleFromCenterHorizontalBar(obj.h_median.XData,scale_factor);
                end
                
                if in.scale_extent_bars
                    %Currently assuming same width top and bottom ...
                    if ~isempty(obj.h_upper_extent_bar)
                        x_data = obj.h_upper_extent_bar.XData;
                        x_data2 = h__scaleFromCenterHorizontalBar(x_data,scale_factor);
                        obj.h_upper_extent_bar.XData = x_data2;
                        obj.h_lower_extent_bar.XData = x_data2;
                    end
                end
                
                obj.h__box_width = new_width;
            end
        end
        function changeXLocation(objs,x_locations)
            %JAH: At this point ...
            keyboard
            %We also need to move the x-ticks ... :/
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
                        
                        
                        pos = [obj.x_center - half_width,...
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

%TODO: These are basic manipulations that could be moved to std lib ...
%TODO: Move these helper functions ...
function x_data_out = h__scaleFromCenterHorizontalBar(x_data_in,scale_factor)

old_bar_width = diff(x_data_in);
old_half_bar_width = old_bar_width/2;
new_bar_width = old_bar_width*scale_factor;
new_half_bar_width = new_bar_width/2;
shift = new_half_bar_width - old_half_bar_width;
x_left = x_data_in(1)-shift;
x_right = x_data_in(2)+shift;
x_data_out = [x_left x_right];


end

function pos_data_out = h__scaleFromCenterPosition(pos_data_in,scale_factor)

                %New: 0.5
                %Old: 0.3
                %
                %Left side:
                %x_old = 0.8
                %x_new = 0.6 = x_old - 0.2 = x_old - (new - old)

    old_width = pos_data_in(3);
    new_width = old_width*scale_factor;
    shift  = 0.5*(new_width - old_width);
    pos_data_out = pos_data_in;
    pos_data_out(1) = pos_data_out(1)-shift;
    pos_data_out(3) = new_width;
    

%     old_half_width = obj.box_width/2;
%                 
%                 
%                 
%                 %New: 0.5
%                 %Old: 0.3
%                 %
%                 %Left side:
%                 %x_old = 0.8
%                 %x_new = 0.6 = x_old - 0.2 = x_old - (new - old)
%                 shift = new_half_width - old_half_width;
%                 
%                 %TODO: Make this a function ...
%                     %TODO
%                     p = obj.h_box.Position;
%                     p(1) = p(1)-shift;
%                     p(3) = new_width;
%                     obj.h_box.Position = p;
end




