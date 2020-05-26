function ylim = getDataYExtents(h_axes,varargin)
%
%   ylim = sl.hg.axes.getDataYExtents(h_axes,varargin)
%
%   Computs min and max of all lines in an axes ...
%
%   Note, if the process fails it returns the current limits of the axes.
%
%   Optional Inputs
%   ---------------
%   xlim : [min max], default []
%       If not empty computes y limits over a given x - range
%   pct_range_extend : [lower upper] OR [both]
%       How much to extend the ylimit based on a percentage of the data
%       range. + values expand, - values shrink
%   round : default true
%       If true the numbers are rounded to values that are a percentage of
%       the spanned range. Currently this is rounded to 2 decimals or
%       places after the most significant digit in the range.
%           For example, consider observed limits => [0.0123 4.986] > this
%       spans roughly 5 units, so we'll round roughly to the 100ths
%       place => [0.01 4.99]
%           Note too that we round using floor(ylim(1)) and ceil(ylim(2))
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
%
%   %expand lower limit, shrink upper limit
%   ylim = sl.hg.axes.getDataYExtents(h_axes,'pct_range_extend',[0.1 -0.1]);
%   ylim => [-12 8]
%
%   %expand both sides
%   ylim = sl.hg.axes.getDataYExtents(h_axes,'pct_range_extend',[0.05]);
%   ylim => [-11 11]
%
%   %Flat line testing
%   plot([0 1],[1 1])
%   ylim = sl.hg.axes.getDataYExtents(gca);
%   ylim => [0.9 1.1]
%
%   %Obnoxious precision
%   plot([0 1],[1.12345 10.789])
%   ylim = sl.hg.axes.getDataYExtents(gca);
%   ylim => [1.12 10.79]
%   

in.round = true;
in.pct_range_extend = [];
in.xlim = [];
in.same_action = 'pct';
%   TODO: Document this, basically if we have a flat line
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

if ~y_set
    ylim = h_axes.YLim;
    return
end

if ylim(1) == ylim(2)
   switch in.same_action
       case 'pct'
           ylim(1) = 0.9*ylim(1);
           ylim(2) = 1.1*ylim(2);
       otherwise
           error('Only "pct" option is recognized for flat lines')
   end
end

if ~isempty(in.pct_range_extend)
    r = diff(ylim);
    extra = in.pct_range_extend.*r;
    if length(extra) == 1
        ylim(1) = ylim(1)-extra;
        ylim(2) = ylim(2)+extra;
    else
        ylim(1) = ylim(1)-extra(1);
        ylim(2) = ylim(2)+extra(2);
    end
end

if in.round
    range = diff(ylim);
    rounding_power = floor(log10(range))-2;
    %0 => -2 => 2 decimals
    %3 => 1 => -1 keep 1s place
%     ylim = round(ylim,-1*rounding_power);
    ylim(1) = sl.array.roundToPrecision(ylim(1),10^rounding_power,@floor);
    ylim(2) = sl.array.roundToPrecision(ylim(2),10^rounding_power,@ceil);
    
end


end