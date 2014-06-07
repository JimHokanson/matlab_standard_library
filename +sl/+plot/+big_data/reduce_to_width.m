function [x_reduced, y_reduced] = reduce_to_width(x, y, axis_width_in_pixels, x_limits)
%
% [x_reduced, y_reduced] = sl.plot.big_data.reduce_to_width(x, y, width, lims)
% 
%   For a given data set, this function returns the maximum and minimum
%   points within non-overlapping subsets of the data, bounded by the 
%   specified limits.
%
%   This helps us to increase the rate at which we can plot data.
%
%   Inputs
%   ------
%   x : 
%       [samples x channels], TODO: Support sci.time_series.time
%   y : 
%   axis_width_in_pixels : 
%       This specifies the number of min/max pairs to generate.
%   x_limits : 
%       2 element vector [min,max], can be [-Inf Inf] to indicate everything
%       This limit is applied to the 'x' input to exclude any points that 
%       are outside the limits.
%
%   Outputs
%   -------
%   x_reduced :
%   y_reduced :
%
%   
%   Example
%   -------
%   [xr, yr] = sl.plot.big_data.reduce_to_width(x, y, 500, [5 10]);
%
%   plot(xr, yr); % This contains many fewer points than plot(x, y) 
%                 %but looks the same.
%
%   Original Function By:
%   Tucker McClure (Mathworks)

    % We'll need the first point to the left of the limits, the first point
    % to the right to the right of the limits, and the min and max at every
    % pixel inbetween. That's 1 + 1 + 2*(width - 2) = 2*width total points.
    n_points = 2*axis_width_in_pixels;
    
    %TODO: Check x type, support time object ...
    
    % If the data is already small, there's no need to reduce.
    if size(x, 1) <= n_points
        x_reduced = x;
        y_reduced = y;
        return;
    end

    % Reduce the data to the new axis size.
    x_reduced = nan(n_points, size(y, 2));
    y_reduced = nan(n_points, size(y, 2));
    for k = 1:size(y, 2)

        % Find the starting and stopping indices for the current limits.
        if k <= size(x, 2)
            
            xt = x(:, k);

            % Map the lower and upper limits to indices.
            nx = size(x, 1);
            lower_limit      = binary_search(xt, x_limits(1), 1,           nx);
            [~, upper_limit] = binary_search(xt, x_limits(2), lower_limit, nx);
            
            % Make the windows mapping to each pixel.
            x_divisions = linspace(x(lower_limit, k), ...
                                   x(upper_limit, k), ...
                                   axis_width_in_pixels + 1);
                               
        end

        % Create a place to store the indices we'll need.
        indices = [lower_limit, zeros(1, n_points-2), upper_limit];
        
        % For each pixel...
        right = lower_limit;
        for z = 1:axis_width_in_pixels-1
            
            % Find the window bounds.
            left               = right;
            [~, right]         = binary_search(xt, ...
                                               x_divisions(z+1), ...
                                               left, upper_limit);
            
            % Get the indices of the max and min.
            yt = y(left:right, k);
            [~, max_index]     = max(yt);
            [~, min_index]     = min(yt);
            
            % Record those indices.
            indices(2*z:2*z+1) = sort([min_index max_index]) + left - 1;
            
        end

        % Sample the original x and y at the indices we found.
        x_reduced(:, k) = xt(indices);
        y_reduced(:, k) = y(indices, k);

    end
    
end

% Binary search to find boundaries of the ordered x data.
function [L, U] = binary_search(x, v, L, U)
    while L < U - 1                 % While there's space between them...
        C = floor((L+U)/2);         % Find the midpoint
        if x(C) < v                 % Move the lower or upper bound in.
            L = C;
        else
            U = C;
        end
    end
end
