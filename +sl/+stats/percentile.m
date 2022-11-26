function y = percentile(data,p,varargin)
%
%   y = sl.stats.percentile(data,p,varargin)
%
%   Optional Inputs
%   ---------------
%   
%
%   Examples
%   --------
%   data = [1 2 3 4 5];
%   p = 50;
%   y = sl.stats.percentile(data,p);
%   
%
%   data = rand(1000,1);
%
%   data = 1:1000;
%   p = 0:100;
%   y = sl.stats.percentile(data,p);
%
%   y1 = prctile(data,p);
%   y2 = sl.stats.percentile(data,p);


in.method = 'linear_ml';
in = sl.in.processVarargin(in,varargin);

%{
%https://numpy.org/doc/stable/reference/generated/numpy.percentile.html
inverted_cdf
averaged_inverted_cdf
closest_observation
interpolated_inverted_cdf
hazen
weibull
linear (default)
median_unbiased
normal_unbiased
%}


x = sort(data);
n = length(x);

%linear
%-------------------------------------------
switch in.method
    case {'linear','linear_ml'}
        %x - percent
        %y - index
        if strcmp(in.method,'linear')
            x0 = 0;
            x1 = 100;
        else
            x0 = 100*0.5/n;
            x1 = 100*(n-0.5)/n;
        end
        
        y0 = 1;
        y1 = n;

        m = (y1-y0)/(x1-x0);
        %y = m*x+b
        b = y1 - m*x1;

        target_index = m*p+b;
        if strcmp(in.method,'linear_ml')
           target_index(target_index < 1) = 1;
           target_index(target_index > n) = n; 
        end
        left_index = floor(target_index);
        right_index = ceil(target_index);

        index_delta = (x(right_index)-x(left_index));
        pct_step = (target_index-left_index);

        %TODO: This should be cleaned up a bit
        if ~isequal(size(pct_step),size(index_delta))
            pct_step = pct_step';
        end

        y = x(left_index)+pct_step.*index_delta;

end