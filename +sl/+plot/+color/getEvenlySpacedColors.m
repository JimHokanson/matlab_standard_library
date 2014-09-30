function var_color = getEvenlySpacedColors(N, varargin)
%getEvenlySpacedColors Creates a matrix of N evenly space colors
%
%   var_color = sl.plot.color.getEvenlySpacedColors(N,varargin)
%
%   hsv2rgb(hues(varying over n),sat,val)

in.sat = 1;
in.val = 1;
in = sl.in.processVarargin(in,varargin);

% Create a list of even spaced colors, using a HSV to RGB transformation.

if N > 0
    if N == 1
        % avoid divide by 0
        hues = .5;
    else
        hues = linspace(0,1-1/N,N);
    end
    
    var_color = hsv2rgb([hues', ...
        in.sat*ones(N,1),...
        in.val*ones(N,1)]);
end

