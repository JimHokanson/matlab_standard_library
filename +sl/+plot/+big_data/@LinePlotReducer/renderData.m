function renderData(obj,s)
% Draws all of the data.
%
%   This is THE main function which actually plots data.
%
%   Inputs:
%   -------
%   s : (struct)
%       h : Axes
%       event_data : matlab.graphics.eventdata.SizeChanged (2014b)
%                    ??? (pre 2014b)
%       axes_I :
%
%   This function is called:
%       1) manually
%       2) list is incomplete TODO: Finish this...
%
%   See Also:
%   resize

%TODO: Add a callback such that when the old lines are deleted, the calls
%associated with those lines are deleted
%
%How to identify problem:
%------------------------
%plot figure
%clear object
%plot figure again, overriding
%resize things
%you should now see 2 callbacks, even though one isn't really rendering
%- or shouldn't be

INITIAL_AXES_WIDTH = 2000;
TIMER_START_DELAY = 0.5;

if nargin == 1
    s = [];
end

obj.n_render_calls = obj.n_render_calls + 1;

% We're busy now.
obj.busy = true;

%If the figure closes, and we ask the object to replot things, than
%that would be a problem.
if obj.plotted_data_once
    for iG = obj.n_plot_groups
        if any(~ishandle(obj.h_plot{iG}))
            obj.h_axes = [];
            obj.plotted_data_once = false;
            break
        end
    end
end

% NOTE: Due to changes in the way this function was designed,
% we may not have plotted the original data yet
if ~obj.plotted_data_once
    
    %NOTE: The user may have already specified the axes ...
    if isempty(obj.h_axes)
        obj.h_axes   = gca;
        obj.h_figure = gcf;
        plot_args = {};
    elseif isempty(obj.h_figures)
        obj.h_figure = get(obj.h_axes(1),'Parent');
        plot_args = {obj.h_axes};
    else
        plot_args = {obj.h_axes};
    end
    
    %Will there ever be more than one axes with this approach?
    %axes_width = sl.axes.getWidthInPixels(obj.h_axes);
    
    %NOTE: Going large here will only impact initial memory requirements.
    %---------------------------------------------------------------------
    %memory requirements assuming a large # of samples:
    %2 * n_channels * width
    %
    %Generally this should be relatively small compared to the size of the
    %data.
    
    axes_width = INITIAL_AXES_WIDTH;
    
    obj.axes_width = axes_width;
    
    end_h = 0;
    temp_h_indices = cell(1,obj.n_plot_groups);
    
    group_x_min = zeros(1,obj.n_plot_groups);
    group_x_max = zeros(1,obj.n_plot_groups);
    
    for iG = 1:obj.n_plot_groups
        
        start_h = end_h + 1;
        end_h = start_h + size(obj.y{iG},2) - 1;
        temp_h_indices{iG} = start_h:end_h;
        %Reduce the data.
        %----------------------------------------
        [x_r, y_r] = sl.plot.big_data.reduce_to_width(...
            obj.x{iG}, obj.y{iG}, axes_width, [-Inf Inf]);
        
        group_x_min(iG) = min(x_r(1,:));
        group_x_max(iG) = max(x_r(end,:));
        
        obj.x_r_orig{iG} = x_r;
        obj.y_r_orig{iG} = y_r;
        
        obj.x_r_last{iG} = x_r;
        obj.y_r_last{iG} = y_r;
        
        plot_args = [plot_args {x_r y_r}]; %#ok<AGROW>
        
        cur_linespecs = obj.linespecs{iG};
        if ~isempty(cur_linespecs)
            plot_args = [plot_args {cur_linespecs}]; %#ok<AGROW>
        end
        
    end
    obj.x_lim_original = [min(group_x_min) max(group_x_max)];
    
    %Don't set to 1, figure could close and then
    %we rerun this section of code
    obj.n_x_reductions = obj.n_x_reductions + 1;
    
    if ~isempty(obj.extra_plot_options)
        plot_args = [plot_args obj.extra_plot_options];
    end
    
    %NOTE: We plot everything at once, as failing to do so can
    %cause lines to be dropped.
    %
    %e.g.
    %   plot(x1,y1,x2,y2)
    %
    %   If we did:
    %   plot(x1,y1)
    %   plot(x2,y2)
    %
    %   Then we wouldn't see plot(x1,y1), unless we changed
    %   our hold status, but this could be messy
    
    %The actual plotting:
    %--------------------
    %NOTE: This doesn't support stairs or plotyy
    temp_h_plot = obj.plot_fcn(plot_args{:});
    
    obj.last_redraw_used_original = true;
    obj.x_lim = get(obj.h_axes,'xlim');
    
    %Break up plot handles to be grouped the same as the inputs were
    %---------------------------------------------------------------
    %e.g.
    %plot(x1,y1,x2,y2)
    %This returns one array of handles, but we break it back up into
    %handles for 1 and 2
    %{h1 h2} - where h1 is from x1,y1, h2 is from x2,y2
    obj.h_plot = cell(1,obj.n_plot_groups);
    for iG = 1:obj.n_plot_groups
        obj.h_plot{iG} = temp_h_plot(temp_h_indices{iG});
    end
    
    
    
    h__setupCallbacksAndTimers(obj,TIMER_START_DELAY)
    
    obj.plotted_data_once = true;
    
    
else
    % Get the new limits. Sometimes there are multiple axes stacked
    % on top of each other. Just grab the first. This is really
    % just for plotyy.
    cur_x_lim  = get(obj.h_axes(1), 'XLim');
    
    axes_width = sl.axes.getWidthInPixels(obj.h_axes(1));
    
    %TODO: At this point we need to be able to short-circuit the rendering
    %if not that much has changed.
    %
    %Possible changes:
    %1) Axes is now wider    - redraw if not sufficiently oversampled
    %2) Axes is now narrower - don't care
    %3) Xlimits have changed :
    %       - Gone back to original - use original values
    %       -
    %
    %   Hold onto:
    %   - last axes width
    %   - original axes width
    %
    %   ???? How can we subsample appropriately???
    
    
    %??? - Why was the width 0?
    if axes_width <= 0
        axes_width = 100;
    end
    
    previous_axes_width = obj.axes_width;
    
    x_lim_changed = ~isequal(obj.x_lim,cur_x_lim);
    %width_changed = axes_width ~= previous_axes_width;
    
    use_original = false;
    
    if x_lim_changed
        %x_lim changed almost always means a redraw
        %Let's build a check in here for being the original
        %If so, go back to that
        if cur_x_lim(1) <= obj.x_lim_original(1) && cur_x_lim(2) >= obj.x_lim_original(2)
            %Then the limits span the original limits
            %
            %TODO: Should check that things are wide enough, but we're
            %starting off very wide above, so for now we'll go with the
            %original
            %i.e. if our original was small, and now our figure is larger,
            %then using the decimation for the original would not be
            %appropriate
            if obj.last_redraw_used_original
                return
            else
                use_original = true;
            end
        end
    else
        %Then width changed
        if previous_axes_width < axes_width
            return
        end
        
        %When we expand initially, we will assume we've oversampled enough
        %to not warrant a redraw
        if cur_x_lim(1) <= obj.x_lim_original(1) && cur_x_lim(2) >= obj.x_lim_original(2)
            if obj.last_redraw_used_original
                return
            else
                use_original = true;
            end
        end
        
    end
    
    if use_original
        obj.last_redraw_used_original = true;
    else
        obj.n_x_reductions = obj.n_x_reductions + 1;
    end
    
    obj.axes_width = axes_width;
    
    for iG = 1:obj.n_plot_groups
        
        %Reduce the data.
        %----------------------------------------
        if use_original
            %
            x_r = obj.x_r_orig{iG};
            y_r = obj.y_r_orig{iG};
            
        else
            [x_r, y_r] = sl.plot.big_data.reduce_to_width(...
                obj.x{iG}, obj.y{iG}, axes_width, lims);
        end
        
        local_h = obj.h_plot{iG};
        % Update the plot.
        for iChan = 1:length(local_h)
            set(local_h, 'XData', x_r(:,iChan), 'YData', y_r(:,iChan));
        end
    end
    
end

if ~isempty(obj.post_render_callback)
    obj.post_render_callback();
end

% We're no longer busy.
obj.busy = false;

end

function h__setupCallbacksAndTimers(obj,TIMER_START_DELAY)
%In 2014b the position property no longer changes when the figure is
%resized.
if verLessThan('matlab', '8.4')
    size_cb = {'Position', 'PostSet'};
else
    %You could guess at this call from:
    %   wtf = metaclass(gca)
    %   {wtf.EventList.Name}
    size_cb = {'SizeChanged'};
end


timer_ca = cell(1,length(obj.h_axes));
% Listen for changes to the x limits of the axes.
for k = 1:length(obj.h_axes)
    addlistener(obj.h_axes(k), 'XLim', 'PostSet', @(h, event_data) obj.resize(h,event_data,k));
    
    %In 2014b this doesn't seem to do anything ...
    %Not sure if that was the case in earlier versions ...
    addlistener(obj.h_axes(k), size_cb{:}, @(h, event_data) obj.resize(h,event_data,k));
    t = timer;
    t.StartDelay = TIMER_START_DELAY;
    timer_ca{k} = t;
end

%TODO: For each axes, get which groups of h_plots belong to the axes

obj.timers = [timer_ca{:}];
end