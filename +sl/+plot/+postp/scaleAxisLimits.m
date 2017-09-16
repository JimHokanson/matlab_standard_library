function scaleAxisLimits(scale,h)
%x  Scale axis limits by a given factor
%
%   sl.plot.postp.scaleAxisLimits(*scale,*h)
%
%   This function can be useful to ensure that lines are not overlapping
%   with the edges of an axes.
%
%   Optional Inputs
%   ---------------
%   scale : default 1.1
%   h : default gca
%   
%   Baseed on
%   ---------
%   gzoom.m by Michael R. Gustafson II (mrg@duke.edu)
%
%   Examples
%   --------
%   % 1) Make the limits larger by 10%
%   sl.plot.postp.scaleAxisLimits();


if nargin < 2
    h = gca;
end

if nargin < 1
    scale = 1.1;
end

v = axis(h);

x_range = (v(2)-v(1));
y_range = (v(4)-v(3));
axis(h, v + 0.5*(scale - 1)*[-x_range x_range -y_range y_range]);