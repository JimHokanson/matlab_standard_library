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
%       Formats:
%       - 1#  => [xy]  => 1.1 => increases horizontal and vertical scaling by 10%
%       - 2#s => [x y] => [1 1.1] => does not scale the horizontal, 
%           but scales the vertical by 10%
%       - 4#s => [-x +x -y +y] => [1, 1, 1, 1.1] =>  scaling, this example
%           scales only +y by 10%. Note in the other examples the 10%
%           is split in half across + and - directions so that the total
%           increase is 10%. In this case no such splitting occurs.  
%   h : default gca
%       Axes handle
%   
%   Baseed on
%   ---------
%   gzoom.m by Michael R. Gustafson II (mrg@duke.edu)
%
%   Improvements
%   ------------
%   1) Allow a 4 element vector as well
%   left,right,bottom,top
%
%   Examples
%   --------
%   TODO: Wrap all as one example with subplot
%   % 1) Make the limits larger by 10%
%   plot(1:10)
%   sl.plot.postp.scaleAxisLimits();
%
%   % 2) Make the limits smaller by 10%
%   plot(1:10)
%   sl.plot.postp.scaleAxisLimits(0.9);  
%
%   % 3) Expand only the vertical axis
%   plot(1:10)
%   sl.plot.postp.scaleAxisLimits([1 1.2]);  
%
%   % 4) Expand only to the right
%   plot(1:10)
%   sl.plot.postp.scaleAxisLimits([1 1.2 1 1]);

if nargin < 2 || isempty(h)
    h = gca;
end

if nargin < 1
    scale = 1.1;
end

%For right now, make everything 
if length(scale) == 1
    scale = 0.5*(scale-1)*ones(1,4);
elseif length(scale) == 2
    scale = [0.5*(scale(1)-1)*ones(1,2) 0.5*(scale(2)-1)*ones(1,2)];
elseif length(scale) == 4
    scale = (scale-1);
else
    error('Unexpected scale size')
end


v = axis(h);

x_range = (v(2)-v(1));
y_range = (v(4)-v(3));
%axis([XMIN XMAX YMIN YMAX])
axis(h, v + scale.*[-x_range x_range -y_range y_range]);