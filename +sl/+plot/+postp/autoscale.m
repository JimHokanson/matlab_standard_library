function autoscale(h_axes)
%
%
%   sl.plot.postp.autoscale(h_axes)
%
%   Approaches:
%   -----------
%   1) Mean and Standard deviation
%   2) CDF

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

%TODO: Implement y std

keyboard



%Now determine an appropriate range