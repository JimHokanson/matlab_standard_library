function varargout = verticalLines(x_positions,varargin)
%x Plots vertical lines on a graph ...
%
%   line_handles = sl.plot.type.verticalLines(x_positions,varargin)
%
%   Plots vertical lines on an axes. Requires HG2 graphics (Matlab > 2014B)
%
%   Inputs
%   ------
%   x_positions : array
%       Positions along x-axis of where to include vertical lines
%
%   Optional Inputs
%   ---------------
%   hide_from_legend : default true
%       If true the line does not show up in the legend
%   ylim_include : default false
%       If false, then these lines do not impact Matlab's calculation
%       of the y-limits. If true these lines could cause the y-limits
%       to change.
%   x_as_pct : false (NYI)
%       If true the x values should be related to the axis size.
%   y_values: [n 2] numeric array
%       Column 1: y starts
%       Column 2: y stops
%   y_pct_vary_with_zoom : default true
%       If 'y_pct' is used and this value is true, then the vertical lines
%       are updated every time the ylim changes.
%   y_pct : [n 2] numeric array
%       For when the values are meant to specified in terms of the viewing
%       limits. Values should generally be from 0 to 1 ...
%   parent : axes handle
%       Which axes to put the lines in.
%
%   Optional Line Inputs
%   --------------------
%   You can also specify line properties as optional inputs (see examples)
%
%   Examples
%   --------
%   %1) plot vertical lines at 2,4,6
%   plot(1:10)
%   line_handles = sl.plot.type.verticalLines([2,4,6])
%
%   %2) plot vertical lines at 2,4,6 with extra line specific options
%   ax = subplot(2,1,1);
%   plot(1:10)
%   subplot(2,1,2);
%   plot(1:20)
%   line_handles = sl.plot.type.verticalLines([2,4,6],'parent',ax,'color','k')
%
%   %3) Plot using percentages that change on zooming
%   plot(1:10)
%   y_pcts = [0.4 0.6; 0.3 0.7; 0.2 0.8];
%   line_handles = sl.plot.type.verticalLines([2,4,6],'y_pct',y_pcts,'y_pct_vary_with_zoom',true)
%
%   Improvements
%   -------------
%   1) Allow single line plotting using NaN
%   2) Allow adding text as well for the lines ...
%   3) The vertical lines callback always changes the ylimits because
%   we don't hold onto the previous ylimits with a handle object. This
%   could be improved (performance improvement).
%
%   See Also
%   --------
%   sl.plot.type.horizontalLines
%   sci.time_series.discrete_events>plot

%A potentially useful reference
%Check this out: http://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline

%The idea here is that the x-values should be interepreted as percents
%of the current axis, not as absolute locations ...
in.x_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_as_pct = false; %NYI
in.single_line = false; %NYI - join all lines with NaN

in.ylim_include = false;
in.hide_from_legend = true;
in.y_pct_vary_with_zoom = true;
in.y_values = [];
in.y_pct = [];
in.strings = {};
in.parent = [];
[local_options,line_options] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
in = sl.in.processVarargin(in,local_options);

n_lines = max([length(x_positions), size(in.y_values,1), size(in.y_pct,1)]);

if n_lines > length(x_positions)
    if length(x_positions) == 1
        %scaler passed in, replicated based on x specification
        x_positions = repmat(x_positions,[n_lines 1]);
    else
        error('Mismatch in the # of lines based on # of x_positions and # of y_values')
    end
end

xs = [x_positions(:) x_positions(:)];

ax = h__getAxes(in);

if ~isempty(in.y_values)
    ys = in.y_values;
else
    temp = get(ax,'ylim');
    if isempty(in.y_pct)
        ys = temp;
    else
        y_range = temp(2)-temp(1);
        ys = in.y_pct;
        ys(:,1) = temp(1)+ ys(:,1)*y_range;
        ys(:,2) = temp(1)+ ys(:,2)*y_range;
    end
end

if size(ys,1) < n_lines
    ys = repmat(ys,[n_lines 1]);
end

inputs = {ax,xs',ys'};

if ~in.ylim_include
    line_handles = line(inputs{:},'YLimInclude','off',line_options{:});
else
    line_handles = line(inputs{:},line_options{:});
end

if in.y_pct_vary_with_zoom && ~isempty(in.y_pct)
    %https://www.mathworks.com/matlabcentral/answers/369377-xlim-listener-for-zoom-reset-and-linkaxes-strange-behavior
    pv = sl.obj.persistant_value;
    pv.value = ax.YLim;
	addlistener(ax.YRuler,'MarkedClean',@(src, evt)h__yZoom(line_handles,ax,in,pv));
    %This misses things ...
    %addlistener(ax, 'YLim', 'PostSet', @(src, evt)h__yZoom(line_handles,ax,in))
end


if in.hide_from_legend
    for i = 1:length(line_handles)
        h = line_handles(i);
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    %Now, if the legend is visible, it won't necessarily update
    %-------------------------------------------------------------------
    if ~isempty(ax.Legend)
        legend(ax,'hide');
        legend(ax,'show');
    end
end

if nargout
    varargout{1} = line_handles;
end

end

function ax = h__getAxes(in)
if ~isempty(in.parent)
    ax = in.parent;
else
    ax = gca;
end
end

function h__yZoom(h_lines,ax,in,pv)
%
%   Update percentages ...
% disp('I ran')

ylim = ax.YLim;
%ylim hasn't really change, don't do anything
if isequal(pv.value,pv)
    return
end

y_range = ylim(2)-ylim(1);
ys = in.y_pct;
ys(:,1) = ylim(1)+ ys(:,1)*y_range;
ys(:,2) = ylim(1)+ ys(:,2)*y_range;
n_lines = length(h_lines);
if size(ys,1) < n_lines
    ys = repmat(ys,[n_lines 1]);
end
for i = 1:length(h_lines)
    h = h_lines(i);
    h.YData = ys(i,:);
end

%Store latest used value ...
pv.value = ylim;

end

