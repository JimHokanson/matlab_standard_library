function ylim = getDataYExtents(h_axes,varargin)
%
%   ylim = sl.hg.axes.getDataYExtents(h_axes,varargin)
%
%   Computs min and max of all lines in an axes ...
%
%   Optional Inputs
%   ---------------
%   xlim : [min max], default []
%       If not empty computes y limits over a given x - range
%
%   Example
%   -------
%   plot(1:10)
%   hold on
%   plot(-1:-1:-10)
%   hold off
%   h_axes = gca;
%   ylim = sl.hg.axes.getDataYExtents(h_axes);
%   ylim = [-10 10]

in.xlim = [];
in = sl.in.processVarargin(in,varargin);

h_line = findobj(h_axes.Children,'Type','line');

if isempty(h_line)
    ylim = h_axes.YLim;
    return
end

ylim = NaN(1,2);
y_set = false;
for i = 1:length(h_line)
    x_data = h_line(i).XData;
    y_data = h_line(i).YData;
    if ~isempty(in.xlim)
        mask = x_data >= in.xlim(1) & x_data <= in.xlim(2);
        y2 = max(y_data(mask));
        y1 = min(y_data(mask));
    else
        y2 = max(y_data);
        y1 = min(y_data);
    end
    
    if ~isempty(y1)
        if y_set
            if y1 < ylim(1)
                ylim(1) = y1;
            end
            if y2 > ylim(2)
                ylim(2) = y2;
            end
        else
            y_set = true;
            ylim(1) = y1;
            ylim(2) = y2;
        end
    end
end

end