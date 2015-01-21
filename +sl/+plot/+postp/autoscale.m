function autoscale(h_axes)
%
%
%   sl.plot.postp.autoscale(h_axes)
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

%CURRENT STATUS:
%Line 306 in sl.plot.big_data.LinePlotReducer.renderData



%TODO: It would be nice to optimize the mean and standard deviation
%
%1) Use mean for standard deviation calculation
%2) Try to reduce memory footprint - variance requires data duplication
%       - could do subsets with combinations

%Do we want to do a filter for lines ????
%findobj()????
c = get(h_axes,'children');

%Handle missing yData later ...

keyboard

n_children = length(c);
n_samples = zeros(1,n_children);
y_means = zeros(1,n_children);
y_vars  = zeros(1,n_children);

%Get min and max of all data sets
for iC = 1:n_children
   p = getappdata(c(iC),'BigDataPointer');
   if isempty(p)
      temp_y_data = get(c(iC),'YData');
   else
      temp_y_data = p.getYData; 
   end
   n_samples(iC) = length(temp_y_data);
   y_means(iC)   = mean(temp_y_data);
   y_vars(iC)    = var(temp_y_data);
end

if n_children == 1
    y_mean = y_means;
    y_variance = y_vars;
else
    y_mean = sum((1./n_children).*y_means);
    y_variance = sl.math.mergeVariances(y_vars,y_means,n_samples);
end

keyboard

y_std = sqrt(y_variance);

y_min = y_mean - 5*y_std;
y_max = y_mean + 5*y_std;


%Let's consider setting y_min and y_max being equal
%--------------------------------------------------
y_range = y_max - y_min;

dist_from_zero = abs(y_mean);

pct_range = dist_from_zero/y_range;

if pct_range < 0.05 %TODO: Move to variable
   y_abs = max(abs(y_min),abs(y_max));
   y_min = -y_abs;
   y_max = y_abs;
end

%TODO: Let's ensure that we're within range
%-------------------------------------------
n_outside = 0;
n_samples_total = sum(n_samples);
for iC = 1:n_children
   p = getappdata(c(iC),'BigDataPointer');
   if isempty(p)
      temp_y_data = get(c(iC),'YData');
   else
      temp_y_data = p.getYData; 
   end
   
   %nnz - is this more memory friendly????
   n_outside = n_outside + sum(temp_y_data > y_max);
   n_outside = n_outside + sum(temp_y_data < y_min);
   
   n_samples(iC) = length(temp_y_data);
   y_means(iC)   = mean(temp_y_data);
   y_vars(iC)    = var(temp_y_data);
end



set(h_axes,'YLim',[y_min y_max])

end

function h__getYData(h_line)


end