function varargout = drawPositionBox(h_axes,varargin)
%   
%   sl.hg.axes.drawPositionBox(h_axes)
%
%   sl.hg.axes.drawPositionBox(h_axes,'type','Position')
%   sl.hg.axes.drawPositionBox(h_axes,'type','OuterPosition')
%   sl.hg.axes.drawPositionBox(h_axes,'type','TightInset')

in.p = [];
in.type = 'Position';
in = sl.in.processVarargin(in,varargin);

h_fig = h_axes.Parent;

if ~strcmp(h_axes.Units,'normalized')
    error('Unhandled case')
end

p = sl.hg.axes.getPosition(h_axes,'type',in.type);
h = annotation(h_fig,'rectangle',p,'Color','r');

if nargout
    varargout{1} = h;
end

end