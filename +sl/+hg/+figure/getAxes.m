function axes_handles = getAxes(fig_handle)
%getFigureAxes  Retruns all plot axes handles
%
%   axes_handles = sl.hg.figure.getAxes(fig)
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
%   Improvements:
%   -------------
%   1) Make guarantees about the order of the objects or allow making
%   guarantees about the order of the axes
%       e.g. 'order','lr_tb' => left to right then top to bottom
%               result_order: 1 2 3 4 5 6 7 8 9
%            'order','tb_lr' => top to bottom then left to right
%               result order: 1 4 7 2 5 8 3 6 9
%
%       Ref. layout
%       1 2 3
%       4 5 6
%       7 8 9
%
%       This would be based on the upper left of the position but it could
%       be adjusted to be based on any order
%
%   See Also: 
%   ---------
%   findobj


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