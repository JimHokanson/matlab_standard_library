classdef LinePlotReducer < handle
    %
    %   Class:
    %   sl.plot.big_data.LinePlotReducer
    %
    %   Manages the information in a standard MATLAB plot so that only the
    %   necessary number of data points are shown. For instance, if the width
    %   of the axis in the plot is only 500 pixels, there's no reason to have
    %   more than 1000 data points along the width. This tool selects which
    %   data points to show so that, for each pixel, all of the data mapping to
    %   that pixel is crushed down to just two points, a minimum and a maximum.
    %   Since all of the data is between the minimum and maximum, the user will
    %   not see any difference in the reduced plot compared to the full plot.
    %   Further, as the user zooms in or changes the figure size, this tool
    %   will create a new map of reduced points for the new axes limits
    %   automatically (it requires no further user input).
    %
    %   Using this tool, users can plot huge amounts of data without their
    %   machines becoming unresponsive, and yet they will still "see" all of
    %   the data that they would if they had plotted every single point.
    %
    %   Examples:
    %   ---------------------------------
    %   LinePlotReducer(t, x)
    %
    %   LinePlotReducer(t, x, 'r:', t, y, 'b', 'LineWidth', 3);
    %
    %   LinePlotReducer(@plot, t, x);
    %
    %   LinePlotReducer(@stairs, axes_h, t, x);
    %
    %   Based On:
    %   ---------
    %   This code is based on:
    %   http://www.mathworks.com/matlabcentral/fileexchange/40790-plot--big-/
    %
    %   It is slowly being rewritten to conform with my standards.
    %
    properties
        
        % Handles
        %----------
        h_figure
        h_axes    %This is normally singular.
        %There might be multiple axes for plotyy.
        
        
        h_plot 
        
        
        % Render Information
        %-------------------
        plot_fcn
        extra_plot_options = {} %These are the parameters that go into
        %the end of a plot function, such as {'Linewidth', 2}
        
        % Original data
        %---------------
        %Note on why non-evenly sampled data is no longer supported well.
        %
        %
        %NOTE: Previously there was a y to x map. This was done because
        %we could have multiple x timelines for each y. The result of this
        %parsing is that when we trim the data, our x 'channels' may not
        %longer be the same size, so we do each y, with its corresponding
        %x, separately.
        %
        %   Example:
        %   x = [m x n], y = [m x n] n = # of channels, rows are samples
        %
        %   Since the time values for each column may be different,
        %   returning over a filtered range may make the reduced x values
        %   no longer a matrix. To fix this the old code split all of the
        %   data up into single x,y pairs x = [m x 1], y = [m x 1]. To
        %   avoid data replication all x values were aligned to the
        %   corresponding y values by indices, something like:
        %
        %   x = [m x 1], y = [m x 3],
        %
        %   y_to_x_map = [1 1 1] %All three y's use the first x
        %
        %   or really x = {[m x 1]} y = {[m x 1] [m x 1] [m x 1]}
        %
        %   This would allow more x's and y's with more or less than 'm'
        %   samples.
        %
        x %cell
        y %cell
        linespecs %cell
        
        % Status
        %-----------
        busy = false %Busy during:
        %- construction
        %- refreshData
        
        post_render_callback = []; %This can be set to render
        %something after the data has been drawn .... Any inputs
        %should be done by binding to the anonymous function.
        
    end
    
    properties (Dependent)
       x_limits
       y_limits
    end
    
    methods
        %TODO: Allow invalid checking as well
        function value = get.x_limits(obj)
           if isempty(obj.h_axes)
               value = [NaN NaN];
           else
               value = get(obj.h_axes,'XLim');
           end
        end
        function value = get.y_limits(obj)
           if isempty(obj.h_axes)
               value = [NaN NaN];
           else
               value = get(obj.h_axes,'YLim');
           end
        end
    end
    
    properties
        plotted_data_once = false
    end
    
    properties (Hidden,Constant)
        reduce_fh = @sl.plot.big_data.reduce_to_width;
    end

    %Constructor
    %-----------------------------------------
    methods
        function o = LinePlotReducer(varargin)
            
            %I'm hiding the initialization details in another file to
            %reduce the high indendtation levels and the length of this
            %function.
            init(o,varargin{:})
        end
    end
    
    methods
        function renderData(o)
            % Draws all of the data.
            %
            %   This is THE main function which actually plots data.
            %
            %   This function is called:
            %   manually
            %
            %   See Also:
            %   resize
            
            % We're busy now.
            o.busy = true;
            
            %TODO: If the figure closes, then we are in trouble ...
            
            % NOTE: Due to changes in the way this function was designed,
            % we may not have plotted the original data yet
            if ~o.plotted_data_once
                %NOTE: The user may have already specified the axes ...
                if isempty(o.h_axes)
                    o.h_axes   = gca;
                    o.h_figure = gcf;
                %TODO: If only the axes are specified, then we should get
                %the figure handle ...
                end
              
                width = sl.axes.getWidthInPixels(o.h_axes(1));
                 
                %Why is this happening?
                if width <= 0
                    width = 100;
                end
                
                n_plots     = length(o.x);
                temp_h_plot = zeros(1,n_plots);
                % For all data we manage...
                for k = 1:n_plots
                    
                    %Reduce the data.
                    %----------------------------------------
                    [x_r, y_r] = o.reduce_fh(o.x{k}, o.y{k}, width, [-Inf Inf]);

                    plot_args = {o.h_axes(1) x_r y_r};
                    
                    cur_linespecs = o.linespecs{k};
                    if ~isempty(cur_linespecs)
                        plot_args = [plot_args {cur_linespecs}]; %#ok<AGROW>
                    end
                    
                    if ~isempty(o.extra_plot_options)
                        plot_args = [plot_args o.extra_plot_options]; %#ok<AGROW>
                    end
                    
                    temp_h_plot(k) = o.plot_fcn(plot_args{:});                    
                end
                
                o.h_plot = temp_h_plot;
                
                % Listen for changes to the x limits of the axes.
                for k = 1:length(o.h_axes)
                    addlistener(o.h_axes(k), 'XLim',     'PostSet', @(~, ~) o.resize);
                    addlistener(o.h_axes(k), 'Position', 'PostSet', @(~, ~) o.resize);
                end
                
                o.plotted_data_once = true;
                
                
            else
                % Get the new limits. Sometimes there are multiple axes stacked
                % on top of each other. Just grab the first. This is really
                % just for plotyy.
                lims  = get(o.h_axes(1), 'XLim');
                
                width = sl.axes.getWidthInPixels(o.h_axes(1));
                
                %??? - Why was the width 0?
                if width <= 0
                    width = 100;
                end
                
                % For all data we manage...
                for k = 1:length(o.x)
                    
                    %Reduce the data.
                    %----------------------------------------
                    [x_r, y_r] = o.reduce_fh(o.x{k}, o.y{k}, width, lims);
                    
                    % Update the plot.
                    set(o.h_plot(k), 'XData', x_r, 'YData', y_r);
                end
            end
            
            if ~isempty(o.post_render_callback)
               o.post_render_callback(); 
            end
            
            % We're no longer busy.
            o.busy = false;
            
        end
        function resize(o)
            % If the user resizes the figure OR if the x limits change, then
            %
            %
            %
            
            %TODO: This needs to be fixed ...
            %
            %It is being called multiple times ...
            %
            %???? Doesn't this approach mean that we'll miss events????
            % If we're not already busy updating and if the plots still exist.
            if ~o.busy && all(ishandle(o.h_plot))
                o.renderData();
                %fprintf('Callback ran\n');
            end
        end
    end
    
    methods (Static)
       test_plotting_speed %sl.plot.big_data.LinePlotReducer.test_plotting_speed 
    end
    
end

%dcm_obj = datacursormode(fig);
%set(dcm_obj,'UpdateFcn',@myupdatefcn)
%
% % function output_txt = h__DataCursorCallback(obj,event_obj)
% % % Display the position of the data cursor
% % % obj          Currently not used (empty)
% % % event_obj    Handle to event object
% % % output_txt   Data cursor text string (string or cell array of strings).
% % 
% % pos = get(event_obj,'Position');
% % output_txt = {['X: ',num2str(pos(1),4)],...
% %     ['Y: ',num2str(pos(2),4)]};
% % 
% % % If there is a Z-coordinate in the position, display it as well
% % if length(pos) > 2
% %     output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
% % end

