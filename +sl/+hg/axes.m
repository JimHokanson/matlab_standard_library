classdef axes < sl.obj.display_class
    %
    %   Class:
    %   sl.hg.axes
    %
    %   Functions that are relevant to axes.
    %
    %   See Also:
    %   sl.plot.subplotter
    %   matlab.graphics.axis.Axes %2014b
    
    properties
        h
        p %sl.hg.axes.position
    end
    
    properties
        units
        width
        height
    end
    
    methods
        function value = get.units(obj)
            value = get(obj.h,'units');
        end
        function value = get.width(obj)
            temp = get(obj.h,'position');
            value = temp(3);
        end
        function value = get.height(obj)
            temp = get(obj.h,'position');
            value = temp(4);
        end
    end
    
    methods
        function obj = axes(h)
            obj.h = h;
            obj.p = sl.hg.axes.position(obj.h,'position');
        end
    end
    
    methods
        function setWidth(obj,value,varargin)
            %
            %
            %   ?? better name than mode
            %
            %    Optional Inputs:
            %    ---------------
            %    mode: {'centered','left','right'}
            %        - 'centered' - keep position centered
            %        - 'left' - keep left side fixed
            %        - 'right' - keep right side fixed
            in.mode = 'c';
            
            switch lower(in.mode(1))
                case 'c'
                case 'l'
                case 'r'
            end
        end
        function setHeight(obj,value,varargin)
            in.mode = 'c';
            
            switch lower(in.mode(1))
                case 'c'
                case 'l'
                case 'r'
            end
        end
        function clearLabel(obj,type)
            %
            %
            %   Examples:
            %   ---------
            %   a = sl.hg.axes();
            %   a.clearLabel('x')
            
            %NOTE: This is really a breakdown across 2014b lines (pre vs post)
            prop_name = [upper(type) 'Label'];
            cur_value = get(obj.h,prop_name);
            if ischar(cur_value)
                set(obj.h,prop_name,'')
            else
                delete(cur_value)
            end
        end
        function clearTicks(obj,type)
            %   Examples:
            %   ---------
            %   a = sl.hg.axes();
            %   a.clearTicks('x')
            
            prop_name = [upper(type) 'Tick'];
            set(obj.h,prop_name,[]);
        end
    end
    
    methods (Static)
        function pixels = getWidthInPixels(h)
            %
            %
            %   pixels = sl.axes.getWidthInPixels(h)
            %
            %   Changing the units triggers a change in size prior to
            %   Matlab 2014b.
            
            % Record the current axes units setting.
            axes_units = get(h, 'Units');
            
            % Change axes units to pixels.
            set(h, 'Units', 'pixels');
            
            % Get axes width in pixels.
            axes_position = get(h, 'Position');
            pixels = round(axes_position(3));
            
            % Return the units.
            set(h, 'Units', axes_units);
        end
    end
    
end

