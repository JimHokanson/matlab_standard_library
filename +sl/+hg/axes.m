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
        position %sl.hg.axes.position
        outer_position
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
            %x Construct axes object from Matlab's axes object
            %   
            %   Inputs:
            %   -------
            %   h : scalar OR matlab.graphics.axis.Axes (2014b & newer)
            %       A handle to the Matlab axes
            %
            
            %TODO: Add on axes check for h
            obj.h = h;
            obj.position = sl.hg.axes.position(obj.h,'position');
            obj.outer_position = sl.hg.axes.position(obj.h,'OuterPosition');
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
            in = sl.in.processVarargin(in,varargin);
            
            p = obj.position;
            switch lower(in.mode(1))
                case 'c'
                    center_y = p.center_y;
                    new_bottom = center_y - 0.5*value;
                    new_top = center_y + 0.5*value;
                case 'l'
                case 'r'
            end
            
            p.top = new_top;
            p.bottom = new_bottom;
            
        end
        function clearLabel(obj,type)
            %
            %   clearLabel(obj,type)
            %   
            %   Inputs:
            %   -------
            %   type : string {'x','y'}
            %
            %   Examples:
            %   ---------
            %   a = sl.hg.axes(gca);
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
            %
            %
            %   Examples:
            %   ---------
            %   a = sl.hg.axes(gca);
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

