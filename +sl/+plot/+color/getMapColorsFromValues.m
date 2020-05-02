function colors = getMapColorsFromValues(map,values,varargin)
%X Gets a value for each color, based on their relative values
%
%   colors = sl.plot.color.getMapColorsFromValues(map,values);
%
%   Values get mapped to [0,1]. A Value of 0 goes to the beginning of the
%   map and a value of 1 goes to the end, and anything in between is
%   linearly interpolated between the values.
%
%   Inputs
%   ------
%   map : [n x 3]
%       Color values to interpolate between
%   values : 
%
%   Optional Inputs
%   ---------------
%   TODO: Document these ...
%
%   Example
%   -------
%   values = 1:10;
%   colors = sl.plot.color.getMapColorsFromValues(colormap('autumn'),values); 
%
%   figure
%   hold on
%   for i = 1:10
%       plot((1:10).*i,'Color',colors(i,:),'LineWidth',2)
%   end
%   hold off

in.min_value = [];
in.max_value = [];
in = sl.in.processVarargin(in,varargin);

if isempty(in.min_value)
    in.min_value = min(values);
end

if isempty(in.max_value)
   in.max_value = max(values); 
end

%TODO: Error check on min and max, max > min

range = in.max_value - in.min_value;

%TODO: Not sure if this is what we want ...
if range == 0
   norm_values = 0.5*ones(1,length(values)); 
else
    norm_values = (values - in.min_value)./range;
end
colors = zeros(length(values),3);

x_i = linspace(0,1,size(map,1));
for i = 1:3
    colors(:,i) = interp1(x_i,map(:,i),norm_values);
end



end