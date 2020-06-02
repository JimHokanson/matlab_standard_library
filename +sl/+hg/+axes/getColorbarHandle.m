function h_color = getColorbarHandle(h_axes)
%
%   h_color = sl.hg.axes.getColorbarHandle(h_axes)
%
%   Output
%   ------
%   h_color : handle or []


    %Not sure if this will always work
    h_color = h_axes.Colorbar;

end