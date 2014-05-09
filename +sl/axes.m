classdef axes
    %
    %   Class:
    %   sl.axes
    
    properties
    end
    
    methods (Static)
        function pixels = getWidthInPixels(h)
            %
            %
            %   pixels = sl.axes.getWidthInPixels(h)
            %
            %   ??? Does changing the units cause a figure redraw?
            
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

