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
%       2) from resize2()
%
%   See Also:
%   sl.plot.big_data.LinePlotReducer.resize2

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

INITIAL_AXES_WIDTH = 2000; %Eventually the idea was to make this a function
%of the screen size

if nargin == 1
    s = [];
end

obj.n_render_calls = obj.n_render_calls + 1;

%If the figure closes, and we ask the object to replot things, than
%that would be a problem, since the graphics references wouldn't exist
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
    %#DEBUG
    %disp('Running first plot code')
    h__handleFirstPlotting(obj,INITIAL_AXES_WIDTH)
    
else
    h__replotData(obj,s,INITIAL_AXES_WIDTH)
    
end

if ~isempty(obj.post_render_callback)
    obj.post_render_callback();
end


end

function h__replotData(obj,s,INITIAL_AXES_WIDTH)


new_x_limits  = s.new_xlim;

%TODO: I'm phasing out resizing, rendering a few thousand point
%line is no big deal ...
new_axes_width = INITIAL_AXES_WIDTH;


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

% % %     origInfo = getappdata(gca, 'matlab_graphics_resetplotview');
% % %     if ~isempty(origInfo)
% % %     fprintf(2,'%s\n',mat2str(origInfo.XLim));
% % %     end

previous_axes_width = obj.last_rendered_axes_width;

x_lim_changed = ~isequal(obj.last_rendered_xlim,new_x_limits);
%width_changed = axes_width ~= previous_axes_width;

use_original = false;

if x_lim_changed
    %x_lim changed almost always means a redraw
    %Let's build a check in here for being the original
    %If so, go back to that
    if new_x_limits(1) <= obj.x_lim_original(1) && new_x_limits(2) >= obj.x_lim_original(2)
        use_original = true;
    end
else
    %Then width changed
    if previous_axes_width < new_axes_width
        return
    end
    
    %When we expand initially, we will assume we've oversampled enough
    %to not warrant a redraw
    if new_x_limits(1) <= obj.x_lim_original(1) && new_x_limits(2) >= obj.x_lim_original(2)
        use_original = true;
    end
    
end

if use_original
    obj.last_redraw_used_original = true;
else
    obj.n_x_reductions = obj.n_x_reductions + 1;
end

obj.last_rendered_xlim = new_x_limits;
obj.last_rendered_axes_width = new_axes_width;

for iG = 1:obj.n_plot_groups
    
    %Reduce the data.
    %----------------------------------------
    if use_original
        %
        x_r = obj.x_r_orig{iG};
        y_r = obj.y_r_orig{iG};
        
    else
        [x_r, y_r] = sl.plot.big_data.reduce_to_width(...
            obj.x{iG}, obj.y{iG}, new_axes_width, new_x_limits);
    end
    
    local_h = obj.h_plot{iG};
    % Update the plot.
    for iChan = 1:length(local_h)
        set(local_h(iChan), 'XData', x_r(:,iChan), 'YData', y_r(:,iChan));
    end
end

% % %     origInfo = getappdata(gca, 'matlab_graphics_resetplotview');
% % %     if ~isempty(origInfo)
% % %         fprintf(2,'%s\n',mat2str(origInfo.XLim));
% % %     end
% % %


end

function h__setupCallbacksAndTimers(obj)
%
%   This function runs after everything has been setup...
%
%   Called by:
%   sl.plot.big_data.LinePlotReducer.renderData>h__handleFirstPlotting


n_axes = length(obj.h_axes);

obj.timers = cell(1,length(obj.h_axes));

%I had setup timers in this function previously, but I was running into
%issues, so I moved them to the callback functions ...

% Listen for changes to the x limits of the axes.

obj.axes_listeners = cell(1,n_axes);

for iAxes = 1:n_axes
    l1 = addlistener(obj.h_axes(iAxes), 'XLim', 'PostSet', @(h, event_data) obj.resize(h,event_data,iAxes));
    
    %TODO: Also update the object that the axes are dirty ...
    l2 = addlistener(obj.h_axes(iAxes), 'ObjectBeingDestroyed',@(~,~)h__handleObjectsBeingDestroyed(obj));
    
    obj.axes_listeners{iAxes} = [l1 l2];
end

n_groups = length(obj.h_plot);

obj.plot_listeners = cell(1,n_groups);

for iG = 1:length(obj.h_plot)
    cur_group = obj.h_plot{iG};
    %NOTE: Technically I think we only need to add on one listener
    %because if one gets deleted, all the others should as well ...
    
    obj.plot_listeners{iG} = addlistener(cur_group(1), 'ObjectBeingDestroyed',@(~,~)h__handleObjectsBeingDestroyed(obj));
end

end

function h__handleObjectsBeingDestroyed(obj)
%This function prevents a memory leak. I'm not sure why it wasn't needed
%in the FEX version ...

%Destory all 

for iAxes = 1:length(obj.h_axes)
   cur_listeners = obj.axes_listeners{iAxes};
   delete(cur_listeners)
end

for iG = 1:length(obj.h_plot)
   cur_listener = obj.plot_listeners{iG};
   delete(cur_listener)
end

obj.needs_initialization = true;

%TODO: Might want to delete timers as well ...
%obj.timers

% t = obj.timers{axes_I};
% if ~isempty(t)
%     try
%         stop(t)
%         delete(t)
%     end
% end



if obj.DEBUG
  disp('Listener cleanup ran')  
end
end



function h__handleFirstPlotting(obj,initial_axes_width)
%
%
%


%NOTE: The user may have already specified the axes ...
%TODO: Verify that the axes exists if specified ...
if isempty(obj.h_axes)
    
    %TODO:
    %                             set(0, 'CurrentFigure', o.h_figure);
    %                     set(o.h_figure, 'CurrentAxes', o.h_axes);
    
    
    obj.h_axes   = gca;
    obj.h_figure = gcf;
    plot_args = {};
elseif isempty(obj.h_figure)
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

new_axes_width = initial_axes_width;

obj.last_rendered_axes_width = new_axes_width;

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
        obj.x{iG}, obj.y{iG}, new_axes_width, [-Inf Inf]);
    
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

%I'm being superstitious
drawnow();

obj.last_redraw_used_original = true;
obj.last_rendered_xlim = get(obj.h_axes,'xlim');

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

h__setupCallbacksAndTimers(obj)

obj.plotted_data_once = true;
end