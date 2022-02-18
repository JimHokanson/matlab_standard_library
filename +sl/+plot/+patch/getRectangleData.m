function s = getRectangleData(x1,x2,y1,y2)
%
%   s = sl.plot.patch.getRectangleData(x1,x2,y1,y2)

x = [x1 x1 x2 x2];
y = [y1 y2 y2 y1];

s.x = x;
s.y = y;


end