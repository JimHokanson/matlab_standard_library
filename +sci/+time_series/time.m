classdef time < handle
    %
    %   Class:
    %   sci.time_series.time
    %
    %   This was initially created for plotting where I don't want to plot
    %   the entire data set so instead of holding onto a full time series
    %   I'm holding onto "instructions" as to how to construct the full
    %   time series
    %
    %   NOTE: I have yet to use this class ...
    
    properties
       start_absolute_time = NaN
       start_relative_time = 0
       dt %seconds
       n_samples
       %units_use
    end
    
    methods
        function obj = time(dt,n_samples)
           obj.dt = dt;
           obj.n_samples = n_samples;
        end
    end
    
end

