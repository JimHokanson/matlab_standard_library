function autoscale(array_of_h_axes,varargin)
%x Adjust the ylimits of a plot to encompass most of the data
%
%   sl.plot.postp.autoscale(array_of_h_axes)
%
%   Attempts to scale the y limits of the plot. The default Matlab behavior
%   is to span the data completely. If artificats are present it is often
%   more desirable to span most of the data rather than all of it.
%
%   I had considered a cdf based approach but calculating the cdf could be
%   very expensive (I think). The current approach instead relies on 
%   
%
%   Inputs:
%   -------
%   h_axes :
%
%   Optional Inputs:
%   ----------------
%   default_plus_minus = 1;
%   move_mean_to_zero_pct = 0.05;
%   max_clipping_expand_pct = 0.01;
%
%
%   Approaches:
%   -----------
%   1) Mean and Standard deviation
%   2) CDF
%
%
%   See Also:
%   ---------
%   sl.math.mergeVariances
%
%   Improvements:
%   -------------
%   1) Calculate mean and standard deviation at the same time
%   2) Return information on how autoscaling was done
%   3) Allow ignoring certain line segments
%
%   TODO: Finish optional input documentation

%CURRENT STATUS:
%Line 306 in sl.plot.big_data.LinePlotReducer.renderData

in.default_plus_minus = 1;
in.move_mean_to_zero_pct = 0.05;
in.max_clipping_expand_pct = 0.01;

for iAxes = 1:length(array_of_h_axes)
    h__autoscaleSingleAxes(array_of_h_axes(iAxes),in);
end

end

function h__autoscaleSingleAxes(h_axes,in)


%Do we want to do a filter for lines ????
%findobj()????
c = get(h_axes,'children');

[y_mean,y_std,n_samples_total] = h__calculateMeanAndStdDev(c);

for iRuns = 1:4
    
    std_scalar = in.default_plus_minus + iRuns - 1;
    
    y_min = y_mean - std_scalar*y_std;
    y_max = y_mean + std_scalar*y_std;
    
    if h__shouldZeroMean(y_mean,y_min,y_max,in)
        y_min = -std_scalar*y_std;
        y_max = std_scalar*y_std;
    end
    
    n_outside = h__getNOutside(c,y_min,y_max);
    
    n_pct_outside = n_outside/n_samples_total;
    
    if n_pct_outside < in.max_clipping_expand_pct 
        break
    end
end

set(h_axes,'YLim',[y_min y_max])

end

function n_outside = h__getNOutside(c,y_min,y_max)
n_outside = 0;
for iC = 1:length(c)
    %nnz - is this more memory friendly????
    temp_y_data = h__getYData(c(iC));
    
    %Consider doing within instead of outside ...
    %higher memory requirements but should be faster ...
    n_outside = n_outside + sum(temp_y_data > y_max);
    n_outside = n_outside + sum(temp_y_data < y_min);
end
end

function zero_mean = h__shouldZeroMean(y_mean,y_min,y_max,in)

y_range = y_max - y_min;

dist_from_zero = abs(y_mean);

pct_range = dist_from_zero/y_range;

zero_mean = pct_range < in.move_mean_to_zero_pct;


end

function [y_mean,y_std,n_samples_total] = h__calculateMeanAndStdDev(c)

%Handle missing yData later ...


n_children = length(c);
n_samples = zeros(1,n_children);
y_means = zeros(1,n_children);
y_vars  = zeros(1,n_children);

delete_mask = false(1,n_children);

%Get min and max of all data sets
for iC = 1:n_children
    temp_y_data   = h__getYData(c(iC));
    if isempty(temp_y_data)
        delete_mask(iC) = true;
    else
        n_samples(iC) = length(temp_y_data);
        y_means(iC)   = mean(temp_y_data);
        y_vars(iC)    = var(temp_y_data);
    end
end

n_samples(delete_mask) = [];
y_means(delete_mask)   = [];
y_vars(delete_mask)    = [];

if n_children == 1
    y_mean = y_means;
    y_variance = y_vars;
else
    y_mean = sum((1./n_children).*y_means);
    y_variance = sl.math.mergeVariances(y_vars,y_means,n_samples);
end

y_std = sqrt(y_variance);

n_samples_total = sum(n_samples);

end

function y_data = h__getYData(h_line)

p = getappdata(h_line,'BigDataPointer');
if isempty(p)
    try
    y_data = get(h_line,'YData');
    catch
       %Happens for text, maybe others
       y_data = []; 
    end
else
    y_data = p.getYData;
end

end