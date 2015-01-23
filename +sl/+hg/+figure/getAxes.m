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


%{

%This might be better to use:

axes_handles = findobj(figure_handles,'type','axes','-not','Tag','legend','-not','Tag','Colorbar');

%NOTE: linkaxes also does the following check. Not sure where this is used,
%i.e., why this would be true.
%
%   It is interesting that instead of initializing the mask directly
%   they go in reverse to initialize. 
%--------------------------------------------------------------------------
% nondatachild = logical([]);
% for k=length(ax):-1:1
%   nondatachild(k) = isappdata(ax(k),'NonDataObject');
% end
% ax(nondatachild) = [];

%}