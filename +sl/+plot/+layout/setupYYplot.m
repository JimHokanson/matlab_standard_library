function ax = setupYYplot(varargin)
%X Setup layour for plots that are on top of each other
%
%   sl.plot.layout.setupYYplot(position)
%
%   Copied from plotyy when all you really want is to have someone
%   set up the plots but do your own custom plotting into each separately.
%
%   **************************
%   This is a work in progress
%   **************************


in.position = [];
in = sl.in.processVarargin(in,varargin);

if ~isempty(in.position)
    ax(1:2) = axes('Position',in.position);
else
    ax(1:2) = axes();
end
ax1 = ax(1);
hold(ax1,'on')
ax1hv = get(ax(1),'HandleVisibility');
ax(2) = axes('HandleVisibility',ax1hv,'Units',get(ax(1),'Units'), ...
    'Parent',get(ax(1),'Parent'));
set(ax(2),'Position',get(ax(1),'Position'));
set(ax(2),'YAxisLocation','right','Color','none', ...
    'XGrid','off','YGrid','off','Box','off', ...
    'HitTest','off');
ax2 = ax(2);
hold(ax2,'on')

end