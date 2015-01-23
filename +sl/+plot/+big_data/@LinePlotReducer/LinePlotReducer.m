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
    %   machines becoming unresponsive, and yet they will still "see" all
    %   of the data that they would if they had plotted every single point.
    %   Zooming in on the data engages callbacks that replot the data in
    %   higher fidelity.
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
    %   See Also:
    %   sci.time_series.data
    
    %{
    Other functions for comparison:
    http://www.mathworks.com/matlabcentral/fileexchange/15850-dsplot-downsampled-plot
    http://www.mathworks.com/matlabcentral/fileexchange/27359-turbo-plot
    http://www.mathworks.com/matlabcentral/fileexchange/40790-plot--big-/
    http://www.mathworks.com/matlabcentral/fileexchange/42191-jplot
    
    %}
    
    
    %TODO: How can we ensure that there are no callbacks left
    %if our quick callbacks isn't fast enough?????
    
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
    
    
    properties (Constant,Hidden)
        %This can be changed to throw out more or less error messages
        DEBUG = 0
        %1) Things related to callbacks
        %2) things from 1) and cleanup
    end
    
    properties
        d0 = '------- User options --------'
        quick_callback_max_wait = 0.1; %If we've waited this long we'll
        %do a quick plot to update. If this were not in place continuous
        %callback events would mean that the plot would never update since
        %its always trying to wait for silence (no events) but events keep
        %coming
        update_delay = 0.1 %This is how long after a zoom request the code
        %should wait before rendering the update. Ideally this is just long
        %enough to capture all resizing events.
        %
        %For example, if multiple axes are linked, there can be many
        %10s of resize events per single axes resize. Ideally the axes
        %resize is only rendered once.
        
        post_render_callback = [] %This can be set to render
        %something after the data has been drawn .... Any inputs
        %should be done by binding to the anonymous function.
        %
        %   e.g. obj.post_render_callback = @()doStuffs(obj)
        %
        %   'obj' will now be available in the callback
        
        max_axes_width = 4000 %Eventually the idea was to make this a function
        %of the screen size
        
        
        % Handles
        %--------
        d1 = '--------  Handles, Listeners, & Timers ------'
        h_figure  %Figure handle. Always singular.
        
        h_axes %This is normally singular.
        %There might be multiple axes for plotyy - NYI
        %
        %   The value is assigned either as an input to the constructor
        %   or during the first call to renderData()
        %
        
        h_plot %cell, {1 x n_groups} one for each group of x & y
        %
        %   e.g. plot(x1,y1,x2,y2,x3,y3) produces 3 groups
        %
        %   This should really be h_line, to be more specific
        
        
        timers %cell, {1 x n_axes} - these are held onto between the
        %callback and the final call by the timer to render the plot
        quick_timers
        
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
        
        
        %TODO: These 2 properties aren't being used
        %We will need to use them for sliding
        %----------------------------------------------------
        x_r_last
        %   This contains the last set of reduced data that was plotted
        y_r_last
        
        last_rendered_axes_width %This is currently not valid as we have
        %hardcoded the render width
        last_rendered_xlim
        x_lim_original
        
        last_render_time = now
        
        busy %This will be used when quick drawing is enabled to prevent
        %quick drawing from ever getting piled up.
        %
        %Right now it is only being used in the timer callback and even
        %there it is only being set, not really used.
        
        %TODO: Add listeners to lines so that when they are deleted
        %everything is deleted
        needs_initialization = true
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
        d4 = '------ Debugging ------'
        id %A unique id that can be used to identify the plotter
        %when working with callback optimization, i.e. to identify which
        %object is throwing the callback (debugging)
        n_resize_calls = 0 %# of times the figure detected a resize
        n_render_calls = 0 %We'll keep track of the # of renders done
        n_x_reductions = 0 %# of times we needed to reduce the data
        %This is the slow part of the code and ideally this is not called
        %very often.
        %
        last_redraw_used_original = true
        last_redraw_was_quick = false
        
        %The goal here is to force a maximum time that occurs
        %before a quick redraw occurs
        %-----------------
        earliest_unhandled_plot_callback_time = []
        %When a callback occurs, if this is empty, it gets set
        %It can then later be used to
    end
    
    %Constructor
    %-----------------------------------------
    methods
        function obj = LinePlotReducer(varargin)
            %x
            %
            %   obj = sl.plot.big_data.LinePlotReducer(varargin)
            %
            %   TODO: Add examples
            %
            temp = now;
            obj.id = uint64(floor(1e8*(temp - floor(temp))));
            %I'm hiding the initialization details in another file to
            %reduce the high indentation levels and the length of this
            %function.
            %sl.plot.big_data.LinePlotReducer.init
            obj.init(varargin{:});
        end
    end
    
    properties
        last_callback_time
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
            %   rendering at a later point in time. Note, this is an update
            %   in the decimation used in this plot NOT an update in the
            %   axes changing. The look of the axes will change, it may
            %   just look a bit funny, specifically if it is being
            %   enlarged.
            %
            %   Every time this callback runs the timer is stopped and the
            %   wait to throw the actual callback begins over again (i.e.
            %   we wait just a bit longer).
            %
            %   Inputs:
            %   -------
            %   h :
            %   event_data :
            %   axes_I :
            %
            %   See Also:
            %   sl.plot.big_data.LinePlotReducer.renderData>h__setupCallbacksAndTimers
            
            obj.n_resize_calls = obj.n_resize_calls + 1;
            
            new_xlim = get(obj.h_axes(axes_I),'xlim');
            
            s = struct;
            s.h = h;
            s.event_data   = event_data;
            s.axes_I       = axes_I;
            s.new_xlim     = new_xlim;
            
            
            t = obj.timers{axes_I};
            obj.timers{axes_I} = [];
            
            %This might occur if we haven't waited long enough
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
            
            last_callback_local = obj.last_callback_time;
            if isempty(last_callback_local)
                obj.last_callback_time = now;
            elseif now - last_callback_local > obj.quick_callback_max_wait/86400
                
                if ~obj.busy
                    %If we call drawnow we don't build up a ton of 
                    %callbacks. I don't completely understand this
                    %but it seems to work.
                    drawnow
                    
                    obj.busy = true;
                    obj.renderData(s,true);
                    obj.last_redraw_was_quick = true;
                    obj.busy = false;
                    obj.last_callback_time = now;
                end
            end
            
            t = timer;
            set(t,'StartDelay',obj.update_delay,'ExecutionMode','singleShot');
            set(t,'TimerFcn',@(~,~)obj.updateAxesData(s));
            start(t)
            
            obj.timers{axes_I} = t;
            
            %#DEBUG
            if obj.DEBUG
                fprintf('Callback called for: %d at %g, xlim: %s: busy: %d\n',...
                    obj.id,cputime,mat2str(new_xlim,2),obj.busy);
            end
            
        end
        function updateAxesData(obj,s)
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
            
            %#DEBUG
            if obj.busy
                h__initializeSlowTimer(obj,s,s.axes_I)
            else
                obj.busy = true;
                if obj.DEBUG
                    fprintf('Callback 2 called for: %d at %g - busy: %d\n',obj.id,cputime,obj.busy);
                end
                
                %NOTE: Once we grab a timer we want to delete it
                %so that the callback can't grab and delete it
                t = obj.timers{s.axes_I};
                obj.timers{s.axes_I} = [];
                
                if ~isempty(t)
                    stop(t)
                    delete(t)
                end
                
                try
                    %We clear this so that on the next change we don't
                    %automatically fire an event
                    obj.last_callback_time = [];
                    obj.renderData(s,false);
                    obj.last_redraw_was_quick = false;
                catch ME
                    %TODO: How do I display the stack without throwing an error?
                    fprintf(2,ME.getReport('extended'));
                    keyboard
                end
                obj.busy = false;
                %             end
            end
            
        end
    end
    
    methods (Static)
        %This should move to the tests class
        test_plotting_speed %sl.plot.big_data.LinePlotReducer.test_plotting_speed
    end
    
end

function h__initializeSlowTimer(obj,s,axes_I)
t = obj.timers{axes_I};
obj.timers{axes_I} = [];

%This might occur if we haven't waited long enough
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
set(t,'StartDelay',obj.update_delay,'ExecutionMode','singleShot');
set(t,'TimerFcn',@(~,~)obj.updateAxesData(s));
start(t)

obj.timers{axes_I} = t;
end
