function colors = getColorsFromColorOrder(n_out,varargin)
%
%   colors = sl.plot.color.getColorsFromColorOrder(n_out,varargin)
%
%   For those that don't know that lines() exists, plus some other options
%   ...
%
%   Improvements
%   ------------
%   support referencing an existing axes

in.color_order = [];
in = sl.in.processVarargin(in,varargin);

color_order = in.color_order;
if isempty(color_order)
    %2019b
    %color_order = colororder;
    color_order = get(0,'DefaultAxesColorOrder');
    
    %Note, technically I think we could just do colors = lines(n_out) here
end

n_order = size(color_order);

colors = zeros(n_out,3);

I = 0;
for i = 1:n_out
    I = I + 1;
    if I > n_order
        I = 1;
    end
    colors(i,:) = color_order(I,:);
end
end