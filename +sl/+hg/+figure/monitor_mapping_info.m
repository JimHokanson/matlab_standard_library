classdef monitor_mapping_info < handle
    %
    %   Class:
    %   monitor_mapping_info
    %
    %   Basically this gives us info about how a figure maps spatially to
    %   monitors. It was written so that I could ask which monitor is
    %   holding the figure. That can be based on the relative area of the 
    %   figure that is over each monitor. Alternatively you can ask where 
    %   each corner of the figure is located (which monitor).
    
    
    %{
        close all
        plot(1:10)
        s = sl.os.getScreenSizes();
    
        %TODO: Write test cases
    %}

    %{
    
    ---
        --------------
                        --------
            --------
    
    --------------
        -----------------
    --------------
        -----------------
    
    %}
    
    properties
        fig_area
        ll
        ul
        ur
        lr
        n_monitors
        pct_on_screen %[1 x n_monitors]
        screen_sizes
    end
    
    methods
        function obj = monitor_mapping_info(h_fig)
            %
            %   obj = sl.hg.figure.monitor_mapping_info(h_fig)
            
            fig = sl.hg.figure.getPixelPosition(h_fig);
            s = sl.os.getScreenSizes();
            
            obj.screen_sizes = s;
            
            obj.n_monitors = length(s);
            
            obj.fig_area = fig.width*fig.height;
            
            areas = zeros(1,length(s));
            for i = 1:length(s)
               screen = s(i); 
               if fig.left > screen.right 
                   %no area
               elseif fig.right < screen.left
                   %no area
               elseif fig.bottom > screen.top
                   %no area
               elseif fig.top < screen.bottom
                   %no area
               else
                   %some overlap exists
                   left = fig.left;
                   right = fig.right;
                   top = fig.top;
                   bottom = fig.bottom;
                   
                   if left >= screen.left
                       if top >= screen.bottom && top <= screen.top
                          obj.ul = i;
                       end
                       if bottom >= screen.bottom && top <= screen.top
                          obj.ll = i; 
                       end
                   end
                   
                   if right <= screen.right
                       if top >= screen.bottom && top <= screen.top
                          obj.ur = i;
                       end
                       if bottom >= screen.bottom && top <= screen.top
                          obj.lr = i; 
                       end
                   end
                   
                   if left < screen.left
                       left = screen.left;
                   end
                   if right > screen.right
                       right = screen.right;
                   end
                   if top > screen.top
                       top = screen.top;
                   end
                   if bottom < screen.bottom
                       bottom = screen.bottom;
                   end
                   
                   width = right-left+1;
                   height = top-bottom+1;
                   
                   areas(i) = width*height;
               end
            end
            
            obj.pct_on_screen = areas./obj.fig_area;
        end
        function flag = figureCompletelyOnAScreen(obj)
            flag = any(obj.pct_on_screen == 1);
        end
        function main_fig_id = getScreenHoldingFigure(obj)
            %
            %   We could add rules ...
            
            %What if they are all 0? I guess it defaults to the 1st ...
            %
            %- we could make that an error
            [~,main_fig_id] = max(obj.pct_on_screen);
        end
    end
end

