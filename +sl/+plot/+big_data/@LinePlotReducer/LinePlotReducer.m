classdef LinePlotReducer < handle
    %
    %   Class:
    %   sl.plot.big_data.LinePlotReducer
    %
    %   Manages the information in a standard MATLAB plot so that only the
    %   necessary number of data points are shown. For instance, if the
    %   width of the axis in the plot is only 500 pixels, there's no reason
    %   to have more than 1000 data points along the width. This tool
    %   selects which data points to show so that, for each pixel, all of
    %   the data mapping to that pixel is crushed down to just two points,
    %   a minimum and a maximum. Since all of the data is between the
    %   minimum and maximum, the user will not see any difference in the
    %   reduced plot compared to the full plot. Further, as the user zooms
    %   in or changes the figure size, this tool will create a new map of
    %   reduced points for the new axes limits automatically (it requires
    %   no further user input).
    %
    %   Using this tool, users can plot huge amounts of data without their
    %   machines becoming unresponsive, and yet they will still "see" all of
    %   the data that they would if they had plotted every single point.
    %
    %   Examples:
    %   ---------
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
    %   See Also:
    %   sci.time_series.data
    
    
    %External Files:
    %---------------
    %1) sl.plot.big_data.LinePlotReducer.init
    %2) sl.plot.big_data.LinePlotReducer.renderData
    
    %Speedup approaches:
    %--------------------------------
    %1) On starting, let's get the widths so that they are apppropriate
    %   for the largest monitor on which they would be displayed.
    %   Eventually we could disable this behavior. Ideally this is not a
    %   significant memory hog.
    %
    %   The current approach is just to use a hardcoded value in renderData
    %
    %2) Oversample the zoom, maybe by a factor of 4ish so that subsequent
    %   zooms can use the oversampled data.
    
    
    
    
    %External Files:
    %sl.plot.big_data.LinePlotReducer.init
    
    properties
        id %A unique id that can be used to identify the plotter
        %when working with callback optimization, i.e. to identify which
        %object is throwing the callback (debugging)
        
        % Handles
        %--------
        d1 = '--------  Handles, Listeners, & Timers ------'
        h_figure  %Figure handle. Always singular.
        
        h_axes %This is normally singular.
        %There might be multiple axes for plotyy - NYI
        
        h_plot %cell, {1 x n_groups} one for each group of x & y
        %
        %   
        %   e.g. plot(x1,y1,x2,y2,x3,y3) produces 3 groups
        %
        %   This should really be h_line, to be more specific
        
        
        timers %cell, {1 x n_axes} - these are held onto between the 
        %callback and the final call by the timer to render the plot
        
        axes_listeners %cell, {1 x n_axes}
        plot_listeners %cell, {1 x n_groups}
        
        % Render Information
        %-------------------
        d2 = '-------  Input Data -------'
        plot_fcn %e.g. @plot

        linespecs %cell 
        %Each element is paired with the corresponding pair of inputs
        %
        %   plot(x1,y1,'r',x2,y2,'c')
        %
        %   linspecs = {{'r'} {'c'}}
        
        extra_plot_options = {} %cell
        %These are the parameters that go into the end of a plot function, 
        %such as {'Linewidth', 2}
        
        
        x %cell Each cell corresponds to a different pair of inputs.
        %
        %   plot(x1,y1,x2,y2)
        %
        %   x = {x1 x2}
        
        y %cell, same format as 'x'
        
        
        d3 = '----- Intermediate Variables ------'
        
        x_r_orig %cell
        %   This is the original reduced data for the full sized plot
        y_r_orig %cell
        
        x_r_last
        %   This contains the last set of reduced data that was plotted
        y_r_last
        
        last_rendered_axes_width
        last_rendered_xlim
        x_lim_original
        
        
        d4 = '------ Options ------'
        post_render_callback = []; %This can be set to render
        %something after the data has been drawn .... Any inputs
        %should be done by binding to the anonymous function.
        %
        %   e.g. obj.post_render_callback = @()doStuffs(obj)
        %
        %   Object will now be available in the callback
        
        
        d5 = '------ Debugging ------'
        n_render_calls = 0 %We'll keep track of the # of renders done
        n_x_reductions = 0
        %for debugging purposes
        last_redraw_used_original = true
        
        busy = false %True during resetting of data
        
        %TODO:
        %-----------------
        earliest_unhandled_plot_callback_time = []
        %When a callback occurs, if this is empty, it gets set
        %It can then later be used to 
        
        

    end
    
    properties (Constant,Hidden)
        %This can be changed to throw out more or less error messages
        DEBUG = 0 
        %1) Things related to callbacks
        %2) things from 1) and cleanup
    end
    
    properties (Dependent)
        n_plot_groups %The number of sets of x-y pairs that we have. See
        %example above for 'x'. In that data, regardless of the size of
        %x1 and x2, we have 2 groups (x1 & x2).
    end
    
    methods
        function value = get.n_plot_groups(obj)
            value = length(obj.x);
        end
    end
    
    properties
        %TODO: Rename to needs_initialization
        %TODO: Add listeners to lines so that when they are deleted
        %everything is deleted
        %- use same objectBeingDestroyed notation as axes
        plotted_data_once = false %Used to determine whether or not
        %we need to do some additional setup.
        needs_initialization = true
    end
    
    %Constructor
    %-----------------------------------------
    methods
        function obj = LinePlotReducer(varargin)
            %
            %   ???
            %
            temp = now;
            obj.id = uint64(floor(1e8*(temp - floor(temp))));
            %I'm hiding the initialization details in another file to
            %reduce the high indentation levels and the length of this
            %function.
            init(obj,varargin{:})
        end
%         function delete(obj)
%             %http://stackoverflow.com/questions/14834040/matlab-free-memory-of-class-objects
%             %#DEBUG
%             %disp('Delete function ran')
%         end
    end
    
    methods
        function resize(obj,h,event_data,axes_I)
            %
            %   Called when the xlim property of an axes object changes or
            %   when an axes is resized (or moved - older versions of
            %   Matlab).
            %
            %   This callback can occur multiple times in quick succession
            %   so we add a timer that essentially requests an update in
            %   rendering at a later point in time. NOTE: This is an update
            %   in the decimation used in this plot NOT an update in the
            %   axes changing. The look of the axes will change, it may
            %   just look a bit funny, specifically if it is being
            %   enlarged.
            %
            %   Every time the callback runs the timer is stopped and the
            %   wait to throw the actual callback begins over again.
            %
            %   Inputs:
            %   -------
            %   h :
            %   event_data :
            %   axes_I :
            %
            %   See Also:
            %   sl.plot.big_data.LinePlotReducer.renderData>h__setupCallbacksAndTimers
            
            %TODO: 
            
            
            START_DELAY = 0.2;
            
            cur_axes = obj.h_axes(axes_I);
            new_xlim = get(cur_axes,'xlim');
            
            
            %#DEBUG
            if obj.DEBUG
                fprintf('Callback called for: %d at %g, xlim: %s: busy: %d\n',obj.id,cputime,mat2str(new_xlim,2),obj.busy);
            end
            
            %This might occur if we haven't waited long enough
            t = obj.timers{axes_I};
            if ~isempty(t)
                try
                    stop(t)
                    delete(t)
                catch
                    %Might fail due to an invalid timer object
                    %NOTE: This is executing asynchronously of the main
                    %code (or is it the timer that is ..., or both)
                    %and we might have deleted the timer in resize2
                end
            end
            
            t = timer;
            set(t,'StartDelay',START_DELAY,'ExecutionMode','singleShot');
            set(t,'TimerFcn',@(~,~)obj.updateAxesData(h,event_data,axes_I,new_xlim));
            start(t)
            
            if obj.DEBUG
                fprintf('New timer created at %g\n',cputime);
            end
            
            
            obj.timers{axes_I} = t;
            
            %Rules for timers:
            %1) Delay action slightly - 0.1 s?
            %2) On calling, delay further
            %
            %   Eventually, if the total delay exceeds some amount, we
            %   should render, this occurs if for example we are panning
            %   ...
        end
        function updateAxesData(obj,h,event_data,axes_I,new_xlim)
            %
            %
            %    This event is called by the timer that is configured in
            %    resize().
            %
            %    If we reach this point then we can begin the slow process
            %    of replotting the data in response to the change in the
            %    axes.
            %
            %    Where does busy fit into this? I don't think it does, we
            %    try and run this code regardless.
            
            %http://www.mathworks.com/matlabcentral/answers/22180-timers-and-thread-safety
            
            
            obj.earliest_unhandled_plot_callback_time = [];
            
            
            %#DEBUG
            if obj.DEBUG
                fprintf('Callback 2 called for: %d at %g - busy: %d\n',obj.id,cputime,obj.busy);
            end
            
            t = obj.timers{axes_I};
            if ~isempty(t)
                stop(t)
                delete(t)
                obj.timers{axes_I} = [];
            end
            
            s = struct;
            s.h = h;
            s.event_data   = event_data;
            s.axes_I       = axes_I;
            s.new_xlim     = new_xlim;
            
            obj.busy = true;
            try
                obj.renderData(s);
            catch ME
                %TODO: How do I display the stack without throwing an error?
                fprintf(2,ME.getReport('extended'));
                keyboard
            end
            obj.busy = false;
            
        end
    end
    
    methods (Static)
        %This should move to the tests class
        test_plotting_speed %sl.plot.big_data.LinePlotReducer.test_plotting_speed
    end
    
end

