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

linkaxes(axes,link_option)