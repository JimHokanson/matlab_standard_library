function p = getPixelPosition(h_fig,varargin)
%
%   p = sl.hg.figure.getPixelPosition(h_fig,varargin);
%
%   Inputs
%   ------
%   h_fig : figure handle
%
%   Optional Inputs
%   ---------------
%   as_sruct : default true

%   On mac, when minimized takes on the position it had before being
%   minimized. On Windows???

in.as_struct = true;
in = sl.in.processVarargin(in,varargin);

temp = getpixelposition(h_fig);

if in.as_struct
    p = struct('left',temp(1),'bottom',temp(2),'width',temp(3),...
        'height',temp(4));
    p.right = p.left + p.width - 1;
    p.top = p.bottom + p.height - 1;
else
    p = temp;
end

end