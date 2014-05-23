function [x_reduced, y_reduced] = reduce_data_for_plotting(x_dt,x_start,y,axis_width,x_limits)
%
%
%   [x_reduced, y_reduced] = sl.plot.reduce_data_for_plotting(x_dt,x_start,y,axes_width,x_limits,varargin)
%
%   Inputs:
%   ------- 
%   y : [n_samples x n_channels]
%       
%   axis_width : ??? - Do I just want to pass in the handle?
%
%   x_limits   : 2 element array [min,max]
%       Contains the minimum and maximum values that x should occupy. These
%       should be real values, not indices.
%
%   Design Notes:
%   --------------
%   This code is based on 'reduce_to_width' in the LinePlotReducer
%   exchange. That code:
%
%   - allowed a variable x step
%   - allowed multiple x 'channels' per 'y' channel
%
%   My code:
%   - requires a single timeline for all channels
%   - does not allow a variable time step
%   - expects the timeline to be formed by 
%
%   See Also:
%   sl.axes.getWidthInPixels



    %Initial setup
    %-------------------------------------------
    [n_samples_data,n_channels] = size(y);

    x_end = x_start + (n_samples_data-1)*x_dt;

    n_regions = axis_width;
    n_reduced_points = 2*n_regions; 
    
    % If the data is already small, there's no need to reduce.
    if n_samples_data <= n_reduced_points
        x_reduced = x_start:x_dt:(x_start+n_samples_data-1);
        y_reduced = y;
        return;
    end
    
    
    %Limit Handling
    %-------------------------------------
    if length(x_limits) ~= 2
        error('The # of values for x_limits should be 2, not %d',length(x_limits));
    end
    
    if x_limits(1) < x_start
        x_limits(1) = x_start;
    end
    
    if x_limits(2) > x_end
       x_limits(2) = x_end; 
    end
    
    %STEP 1: Determine boundaries ...
    %-----------------------------------------------
    x_limits_zeroed = x_limits - x_start;
    x_min_I = ceil(x_limits_zeroed(1))/x_dt;
    x_max_I = floor(x_limits_zeroed(2))/x_dt;
    
    x_bounds = round(linspace(x_min_I,x_max_I,n_regions+1));
    
    
    %STEP 2: Relate boundaries to time
    %-----------------------------------------------
    x_min_time = (x_min_I*x_dt)+x_start;
    x_max_time = (x_max_I*x_dt)+x_start;
    x_reduced  = linspace(x_min_time,x_max_time,n_regions+1);
    
    %STEP 2: Extract min & max for each boundary
    %-----------------------------------------------

    %NOTE: This could be written in mex to speed
    %this process up ...
    y_reduced = zeros(n_reduced_points,n_channels);
    
    cur_data_I = -1;
    for iRegion = 1:n_regions
        cur_data_I = cur_data_I + 2;
        
        left_index  = x_bounds(iRegion);
        right_index = x_bounds(iRegion + 1);
        
        for iChan = 1:n_channels
            yt = y(left_index:right_index,iChan);
        
        [min_val,min_I] = min(yt);
        [max_val,max_I] = max(yt);
        
        if max_I > min_I
            y_reduced(cur_data_I,iChan)   = min_val;
            y_reduced(cur_data_I+1,iChan) = max_val;
        else
            y_reduced(cur_data_I,iChan)   = max_val;
            y_reduced(cur_data_I+1,iChan) = min_val; 
        end
        end
    end
    
    

end