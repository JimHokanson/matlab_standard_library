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
%
%   Other optional inputs are passed to the line handle
%
%   Example:
%   plot(p,'time_units','h','Color','k')
%
%   See Also:
%   sci.time_series.time

%   TODO: How do we want to plot multiple repetitions ...

% in.slow = false;
in.time_units = 's';
in.time_shift = true;
in.time_spacing = [];
in.axes = {};
in.channels = 'all';
[local_options,plotting_options] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
in = sl.in.processVarargin(in,local_options);

time_objs = [objs.time];

if ~isempty(in.time_spacing)
   if ~strcmp(in.time_units,'s')
       error('time spacing not suppported other than by seconds')
   end

   time_objs_for_plot = copy(time_objs);
   last_time_obj = time_objs_for_plot(1);
   for iObj = 2:length(time_objs_for_plot)
       cur_time_obj = time_objs_for_plot(iObj);
       cur_time_obj.start_offset = last_time_obj.end_time + in.time_spacing;
       last_time_obj = cur_time_obj;
   end

else
    start_datetimes = [time_objs.start_datetime];
    if ~sl.array.allSame(start_datetimes) && in.time_shift
    %TODO: Eventually each plotting routine should consult
    %the absolute time that is being used by the first to plot
    %and adjust accoridingly (both units and start time)
            %TODO: Change time objects for plotting
        time_objs_for_plot = copy(time_objs);
        base_datetime = min(start_datetimes);
        dt = sl.datetime.datenumToSeconds(start_datetimes-base_datetime);
        for iObj = 1:length(time_objs_for_plot)
            cur_time_obj = time_objs_for_plot(iObj);
            cur_time_obj.shiftStartTime(dt(iObj));
        end
    else
        time_objs_for_plot = copy(time_objs);
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
    
    if ischar(in.channels)
        temp = big_plot(time_objs_for_plot(iObj),objs(iObj).d,plotting_options{:});
    else
        temp = big_plot(time_objs_for_plot(iObj),objs(iObj).d(:,in.channels),plotting_options{:});
    end
    if ~isempty(in.axes)
        temp.h_axes = in.axes;
    end
    temp.renderData();
    
    render_objs{iObj} = temp;
end

%We want to know start time and units ...
%TODO: This start time might need to change ...
setappdata(gca,'time_series_time',time_objs_for_plot(1));


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
if isempty(cur_obj.units) && isempty(cur_obj.y_label)
    %do nothing
elseif isempty(cur_obj.units)
    ylabel(sprintf('%s',cur_obj.y_label))
elseif isempty(cur_obj.y_label)
    ylabel(sprintf('(%s)',cur_obj.units))
else
    ylabel(sprintf('%s (%s)',cur_obj.y_label,cur_obj.units))
end
xlabel(sprintf('Time (%s)',in.time_units))
end