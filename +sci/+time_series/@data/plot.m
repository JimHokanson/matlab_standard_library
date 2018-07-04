function varargout = plot(objs,varargin)
%x Plot the data, nicely!
%
%   plot_result = plot(obj,varargin)
%
%   Output:
%   -------
%   plot_result : sci.time_series.data.plot_result
%
%   Optional Inputs:
%   ----------------
%   axes
%       -pass in axes to plot on
%   time_units : {'s','min','ms','h'} (default 's')
%       - s , seconds
%       - h , hours
%       - min , minutes
%       - ms , milliseconds
%   channels: default 'all'
%       Pass in the numeric values of the channels to plot.
%   time_shift: (default true)
%       If true, then objects will not be shifted to account
%       for differences in their absolute start times. If not, then there
%       absolute start time is discounted
%   time_spacing: (default [])
%       If not empty, then subsequent trials are spaced by the specified
%       amount (Units: same as 'time_units')
%   zero_time : (default false)
%       If true all plots are zeroed to their first sample.
%
%   Other optional inputs are passed to the line handle
%
%   Time Scale
%   ------------------------------------------
%   TODO: Finish this
%   - zero_time
%   - time_spacing
%   - absolute time
%       If you wish to plot everything relative to a starting absolute time
%       you can set that absolute time by calling:
%
%           big_plot.setAxisAbsoluteStartTime(h_axes,start_time)
%
%           h_axes : desired axes to plot into
%           start_time : absolute time as datenum type
%
%   Example:
%   plot(p,'time_units','h','Color','k')
%
%   See Also:
%   sci.time_series.time

%   TODO: How do we want to plot multiple repetitions ...

% in.slow = false;
%in.use_absolute_time = true;   NYI
in.zero_time = false;
in.quick_plot = true;
in.time_units = 's';
in.time_shift = true;
in.time_spacing = [];
in.axes = {};
in.channels = 'all';
[local_options,plotting_options] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
in = sl.in.processVarargin(in,local_options);

time_objs = [objs.time];

time_objs_for_plot = copy(time_objs);

if ~isempty(in.time_spacing)
    if ~strcmp(in.time_units,'s')
        error('time spacing not suppported other than by seconds')
    end
    
    last_time_obj = time_objs_for_plot(1);
    for iObj = 2:length(time_objs_for_plot)
        cur_time_obj = time_objs_for_plot(iObj);
        cur_time_obj.start_offset = ...
            last_time_obj.end_time + in.time_spacing;
        last_time_obj = cur_time_obj;
    end
    
elseif in.zero_time
    
    for iObj = 1:length(time_objs_for_plot)
        cur_time_obj = time_objs_for_plot(iObj);
        cur_time_obj.start_offset = 0;
    end
else
    %Default behavior
    %--------------------------
    %Shift everything based on minimum start_datetime value
    %or if already specified, the reference start_datetime
    start_datetimes = [time_objs.start_datetime];
    
    if (~sl.array.similiarity.allExactSame(start_datetimes) ...
            && in.time_shift)
        
        %Note, for length(start_datetimes) == 1 this is to force
        %the respect of the previous AxisAbsoluteStartTime
        
        %Get relevant axes
        %--------------------------
        h_axes = in.axes;
        if isempty(h_axes)
            h_axes = gca;
        end
        
        %Determine the first start_datetime
        %-------------------------------------
        base_datetime = big_plot.getAxisAbsoluteStartTime(h_axes);
        if isempty(base_datetime)
            base_datetime = min(start_datetimes);
            big_plot.setAxisAbsoluteStartTime(h_axes,base_datetime);
        end
        
        dt = sl.datetime.datenumToSeconds(start_datetimes-base_datetime);
        for iObj = 1:length(time_objs_for_plot)
            cur_time_obj = time_objs_for_plot(iObj);
            cur_time_obj.shiftStartTime(dt(iObj));
        end
    elseif in.time_shift
        %TODO: This was created for the case of plotting 1 axes at at time
        %
        %It also factors in if we plot a bunch of axes, then more later
        %
        %This code is a bit rough and needs to be cleaned up
         h_axes = in.axes;
        if isempty(h_axes)
            h_axes = gca;
        end
        base_datetime = big_plot.getAxisAbsoluteStartTime(h_axes);
        if ~isempty(base_datetime)
            dt = sl.datetime.datenumToSeconds(start_datetimes-base_datetime);
            for iObj = 1:length(time_objs_for_plot)
                cur_time_obj = time_objs_for_plot(iObj);
                cur_time_obj.shiftStartTime(dt(iObj));
            end
        else
            base_datetime = min(start_datetimes);
            big_plot.setAxisAbsoluteStartTime(h_axes,base_datetime);
        end
    end
end

time_objs_for_plot.changeOutputUnits(in.time_units);


%The actual plotting
%--------------------------------------------------------------
render_objs = cell(1,length(objs));

for iObj = 1:length(objs)
    if iObj == 2
        hold_state = sl.hg.axes.hold_state(gca);
        hold all
    end
    cur_obj = objs(iObj);
    
    %TODO: Consider using plotBig instead of big_plot
    %- has more functionality
    if ischar(in.channels)
        temp = big_plot(time_objs_for_plot(iObj),...
            objs(iObj).d,plotting_options{:});
    else
        temp = big_plot(time_objs_for_plot(iObj),...
            objs(iObj).d(:,in.channels),plotting_options{:});
    end
    
    %TODO: Why isn't this specified with plotting?
    if ~isempty(in.axes)
        temp.h_and_l.h_axes = in.axes;
    end
    temp.renderData();
    
    render_objs{iObj} = temp;
end

%We want to know start time and units ...
%TODO: This start time might need to change ...
if isempty(in.axes)
    setappdata(gca,'time_series_time',time_objs_for_plot(1));
else
    setappdata(in.axes,'time_series_time',time_objs_for_plot(1));
end

if length(objs) > 1
    hold_state.restore();
end

%Populate Output:
%----------------
if nargout
    plot_result = sci.time_series.data.plot_result;
    plot_result.render_objs = render_objs;
    plot_result.axes = render_objs{1}.h_and_l.h_axes;
    varargout{1} = plot_result;
end

%Add labels:
%-----------

if isempty(in.axes)
    in.axes = gca;
end

if isempty(cur_obj.units) && isempty(cur_obj.y_label)
    %do nothing
elseif isempty(cur_obj.units)
    ylabel(in.axes,sprintf('%s',cur_obj.y_label))
elseif isempty(cur_obj.y_label)
    ylabel(in.axes, sprintf('(%s)',cur_obj.units))
else
    ylabel(in.axes,sprintf('%s (%s)',cur_obj.y_label,cur_obj.units))
end
xlabel(in.axes, sprintf('Time (%s)',in.time_units))
end