function linkFigureAxes(fig_handle,link_option)
%
%
%   sl.plot.postp.linkFigureAxes(fig_handle,link_option)
%
%   Inputs:
%   -------
%   fig_handle :
%   link_option : {'x','y','xy'}
%
%   TODO: We could expand link option to include features like linking rows
%   and columns

axes = findobj(fig_handle,'Type','axes');

if isempty(axes)
    error('No axes were found for the current figure handle')
end

%TODO: Have a check here

%Stop incorrectly shrinking things ...
%TODO: This could be its own function
xlim = [Inf -Inf];
ylim = [Inf -Inf];

for iAxes = 1:length(axes)
    cur_axes = axes(iAxes);
    cur_x = get(cur_axes,'xlim');
    cur_y = get(cur_axes,'ylim');
    if cur_x(1) < xlim(1)
        xlim(1) = cur_x(1);
    end
    if cur_x(2) > xlim(2)
        xlim(2) = cur_x(2);
    end
    if cur_y(1) < ylim(1)
        ylim(1) = cur_y(1);
    end
    if cur_y(2) > ylim(2)
        ylim(2) = cur_y(2);
    end
end

if any(strfind(link_option,'x'))
    for iAxes = 1:length(axes)
        cur_axes = axes(iAxes);
        set(cur_axes,'xlim',xlim);
    end
end

if any(strfind(link_option,'y'))
    for iAxes = 1:length(axes)
        cur_axes = axes(iAxes);
        set(cur_axes,'ylim',ylim);
    end
end

%Call to the actual linking code
linkaxes(axes,link_option)