classdef box_plot_entry < handle
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_entry
    
    properties
        group_id
        h_axes
        h
        h_whisker  %vertical????
        h_upper_whisker %vertical portion of whisker
        h_lower_whisker %vertical
        h_upper_extent_bar %top bar
        h_lower_extent_bar %bottom bar
        h_box %position
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
        x_label
    end
    
    methods
        function value = get.x_label(obj)
            value = obj.h__x_label;
            
%             ax = obj.h_axes;
%             
%             cur_x = obj.x_center;
%             x_ticks = ax.XTick;
%             x_tick_labels = ax.XTickLabel;
%             
%             I = find(x_ticks == cur_x,1);
%             if ~isempty(I)
%                 value = x_tick_labels{I};
%             else
%                 value = '';
%             end
        end
        function value = get.x_center(obj)
            value = obj.h__x_center;
        end
        function value = get.box_width(obj)
            value = obj.h__box_width;
        end
    end
    
    properties (Hidden)
        h__x_label = ''
        h__x_center
        h__box_width
    end
    
    methods
        function obj = box_plot_entry(h_axes,handles,data,varargin)
            %
            %   obj = sl.plot.stats.results.box_plot_entry(handles)
            
            in.x = [];
            in.add_n = true;
            in.label = '';
            in.group_id = 1;
            in = sl.in.processVarargin(in,varargin);
            
            obj.group_id = in.group_id;
            
            tag_names = get(handles,'Tag');
            
            %Convert double pointers to objects ...
            %boxplot() returns objects as doubles
            handles = findobj(handles);
            
            obj.h_axes = h_axes;
            obj.h = handles;
            %TODO: Not all components supported ... (see below)
            obj.h_whisker = handles(strcmp(tag_names,'Whisker'));
            obj.h_upper_whisker = handles(strcmp(tag_names,'Upper Whisker'));
            obj.h_lower_whisker = handles(strcmp(tag_names,'Lower Whisker'));
            obj.h_upper_extent_bar = handles(strcmp(tag_names,'Upper Adjacent Value'));
            obj.h_lower_extent_bar = handles(strcmp(tag_names,'Lower Adjacent Value'));
            obj.h_box = handles(strcmp(tag_names,'Box'));
            obj.h_median = handles(strcmp(tag_names,'Median'));
            obj.h_outliers = handles(strcmp(tag_names,'Outliers'));
            
            %Available Styles:
            %-----------------
            %   'traditional'
            %   'traditional' with 'notch' = 'marker'
            %   'compact'
            %   TODO: Finish this ...
            
            %         all styles:  'Box', 'Outliers'
            %        traditional: 'Median', 'Upper Whisker', 'Lower Whisker',
            %                     'Upper Adjacent Value', 'Lower Adjacent Value',
            %            compact: 'Whisker', 'MedianOuter', 'MedianInner'
            %
            %       when 'notch' is 'marker':
            %                     'NotchLo', 'NotchHi'
            
            
            %Log properties about the box
            %-------------------------------------------------
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
            
            if ~isempty(in.x)
                if in.x ~= obj.h__x_center
                    obj.setXCenter(in.x,'move_labels',false);
                end
            end
            
            outlier_y_data = obj.h_outliers.YData;
            
            obj.data = sl.plot.stats.results.box_plot_entry_data(data,...
                outlier_y_data,obj.box_width,obj.x_center);
            
            if ~isempty(in.label)
                obj.setLabel(in.label,in.add_n);
            else
                obj.setLabel(sprintf('%g',obj.x_center),false);
            end
            
        end
        function readdLabels(objs)
            for i = 1:length(objs)
               objs(i).setLabel(objs(i).x_label,false); 
            end
        end
        function setLabel(obj,label,add_n)
            %
            %
            %   setLabel(obj,label,add_n)
            %
            %   

            if add_n
                final_label = sprintf('%s n=%d',label,obj.data.n_data_points);
            else
                final_label = label;
            end
            
            obj.h__x_label = final_label;
            
            ax = obj.h_axes;
            
            cur_x = obj.h__x_center;
            x_ticks = ax.XTick;
            x_tick_labels = ax.XTickLabel(:)';
            
            I = find(x_ticks == cur_x,1);
            if ~isempty(I)
                %ax.XTick = x_ticks;
                x_tick_labels{I} = final_label;
                ax.XTickLabel = x_tick_labels;
            else
                x_ticks = [x_ticks cur_x];
                x_tick_labels = [x_tick_labels final_label];
                [x_ticks_sorted,I] = sort(x_ticks);
                x_labels_sorted = x_tick_labels(I);
                ax.XTick = x_ticks_sorted;
                ax.XTickLabel = x_labels_sorted;
            end
            
        end
        function renderScatterData(objs,varargin)
            %x Renders raw data as scatter plot over box plot
            %
            %   Optional Inputs
            %   ---------------
            %   marker : default 'o'
            %       Shape of the marker.
            %   color : default 'k'
            %       Inner color. No outer color is currently supported
            %   alpha : default 0.6
            %   rng_seed : default 9
            %       This is done to allow reproducability of the random
            %       scatter.
            %   marker_size : default 100
            %   pct_width : default 0.5
            %
            %   See Also
            %   --------
            %   sl.plot.stats.results.box_plot_entry_data
            %   sl.plot.stats.results.box_plot_entry_data>renderScatterData
            
            for i = 1:length(objs)
                obj = objs(i);
                %data : sl.plot.stats.results.box_plot_entry_data
                obj.data.renderScatterData(varargin);
            end
        end
        function setHandlePropValue(objs,prop,varargin)
            %X For each object, set prop to a given value
            %
            %   setHandlePropValue(objs,prop,varargin)
            %
            %   Inputs
            %   ------
            %   prop : string
            %       Name of the property.
            %
            %
            %   Example
            %   -------
            %   setHandlePropValue(obj,'h_box','FaceColor',[0.7 0.7 0.7],'EdgeColor','none')
            
            for i = 1:length(objs)
                obj = objs(i);
                %Note we use varargin because we are not doing:
                %obj.(prop) = value;
                %instead we are calling set, which allows us to change
                %multiple properties at once
                set(obj.(prop),varargin{:})
            end
        end
        function setWidth(objs,new_width,varargin)
            %X
            %
            %   setWidth(objs,new_width,varargin)
            %
            %   This will change box and other relevant widths.
            
            in.scale_extent_bars = true; %NYI
            in.scale_median = true; %NYI => note scaling
            %implies that the median could be at a different scale ...
            in = sl.in.processVarargin(in,varargin);
            
            %TODO: Allow changing median and box independently (and data)
            
            %TODO: Allow scaling top and bottom bar proportionally
            %to the change in
            
            
            for i = 1:length(objs)
                obj = objs(i);
                
                scale_factor = new_width/obj.box_width;
                
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
                
                %TODO: This will need to handle scatter data as well ..
                
                obj.h__box_width = new_width;
            end
        end
        function interleaveGroups(objs,varargin)
            %X Move each index of each group together
            %
            %   interleaveGroups(objs,varargin)
            %
            %   If we start off with something like:
            %
            %   x1 x2 x3 y1 y2 y3  <= boxplots left to right
            %
            %   This function will move the boxplots like this:
            %
            %   x1 y1  x2 y2  x3 y3
            
            in.dx = 1;
            in.dx_group = 1.5; %spacing between groups
            in = sl.in.processVarargin(in,varargin);
            
            group_ids = [objs.group_id];
            
            [u_groups,uI] = sl.array.uniqueWithGroupIndices(group_ids);
            
            %TODO: Add on check that groups are not interleaved
            %i.e. I'm assuming group 1 is 1:x and group 2 is x+1:2x, etc
            %
            %   1 1 1 2 2 2   not 1 2 1 2
            %
            %   Note this is true even after this function runs because
            %   we don't change the order of the objects in the result
            %
            %   We could however pass in shuffled objects ...
            
            n_objects_per_orig_group = cellfun('length',uI);
            
            if ~all(n_objects_per_orig_group == n_objects_per_orig_group(1))
                error('All groups must have the same size for interleaving')
            end
            
            
            n_objects_per_group_new = length(u_groups);
            n_objects = length(objs);
            n_groups = n_objects_per_orig_group(1);
            
            old_x_locations = [objs.h__x_center];
            
            x_start = min(old_x_locations);
            
            %This would ideally be a function
            %-------------------------------------------------------
            new_x1 = x_start:in.dx:(x_start + in.dx*(n_objects_per_group_new-1));
            
            next_group_start = new_x1(end) + in.dx_group;
            
            dx_groups = next_group_start - new_x1(1);
            
            start_offsets = 0:dx_groups:(dx_groups*n_groups-1);
            
            temp = bsxfun(@plus,new_x1(:),start_offsets);
            %-------------------------------------------------------
            new_x_locations = temp(:);
            
            
            % 1 2 3 4 5 6 7 8(groups of 2)
            %
            % 1 5
            % 2 6
            % 3 7
            % 4 8
            %
            % 1 2 3 4
            % 5 6 7 8
            %
            % linearize 1 5 2 6 3 7 4 8
            
            indices = (1:n_objects)';
            indices2 = reshape(indices,[n_groups n_objects_per_group_new])';
            indices3 = indices2(:);
            
            objs2 = objs(indices3);       
            objs2.setXCenter(new_x_locations);
        end
        function setXCenter(objs,new_x_locations,varargin)
            %x
            %
            %   changeXLocation(objs,x_locations,varargin)
            %
            %   Improvements
            %   ------------
            %   1) Support interleaving by group size
            %       Groups are of 4 each, so put 1 and 5 together
            %   2) Support just using a dx input ...
            %   3) Support adding a spacing between groups of different
            %   sizes
            %
            %   NOTE: These might be better as other functions that call
            %   this method ...
            
            
            in.move_labels = true;
            in = sl.in.processVarargin(in,varargin);
            
            old_x_locations = [objs.h__x_center];
            current_labels = {objs.x_label};
            
            for i = 1:length(objs)
                obj = objs(i);
                %Calls process
                
                value = new_x_locations(i);
                center_old = obj.h__x_center;
                dx = value - center_old;
                
                fn = {'h_whisker','h_upper_whisker','h_lower_whisker',...
                    'h_upper_extent_bar','h_lower_extent_bar','h_box','h_median',...
                    'h_outliers'};
                for j = 1:length(fn)
                    cur_name = fn{j};
                    p = obj.(cur_name);
                    if ~isempty(p) && isvalid(p)
                        p.XData = p.XData + dx;
                    end
                end
                
                if isobject(obj.data)
                    obj.data.setXCenter(value)
                end
                
                obj.h__x_center = value;
            end
            
            if in.move_labels
                %   2 4 6 8 10 12
                %   1 3 2 6 4  8
                %    
                %
                
                %                  1  2     3     4     5     6     7     8
                %old_x_locations : 1  3     5     7     2     4     6     8
                %new_x_locations : 1  2     3.5   4.5   6     7    8.5   9.5    
                
                x_ticks = objs(1).h_axes.XTick;
                x_tick_labels = objs(1).h_axes.XTickLabel;
                [mask,loc] = ismember(old_x_locations,x_ticks);
                [mask2,loc2] = ismember(x_ticks,old_x_locations);
                if ~all(mask)
                    error('Unhandled case, not all plots have labels')
                end
                
                x_ticks(loc) = new_x_locations;
                x_tick_labels(loc) = current_labels;
                
                [x_ticks_sorted,I] = sort(x_ticks);
                x_labels_sorted = x_tick_labels(I);
                
                objs(1).h_axes.XTick = x_ticks_sorted;
                objs(1).h_axes.XTickLabel = x_labels_sorted;
            end
            
            %We also need to move the x-ticks ... :/
            %If desired ...
        end
        %setBoxType
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
%
%   x_data_out = h__scaleFromCenterHorizontalBar(x_data_in,scale_factor)
%
%   Note scaling is done such that the center location does not change ...
%
%   Inputs
%   ------
%   x_data_in : [left right]
%
%
%   Outputs
%   -------
%   x_data_out = [left right];

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




