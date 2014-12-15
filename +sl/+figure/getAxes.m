function axes_handles = getAxes(fig_handle)
%getFigureAxes  Retruns all plot axes handles
%
%   hax = sl.figure.getAxes(fig)
%
%   Inputs:
%   -------
%   fig_handle : handle to figure
%
%   Outputs:
%   --------
%   axes_handles  : handles to plot axes
%
%   Restrictions:
%   -------------
%   Type : axes
%   Tag  : currently must be empty
%
%   See Also: findobj


    children = get(fig_handle,'children');
    axes_handles = findobj(children,'Type','axes','Tag','');
end