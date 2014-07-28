classdef time < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.time
    %
    %   obj = sci.time_series.time(dt,n_samples)
    %
    %   This was initially created for plotting where I don't want to plot
    %   the entire data set so instead of holding onto a full time series
    %   I'm holding onto "instructions" as to how to construct the full
    %   time series
    %
    %   I'm slowly working this into functions where I really only
    %   need some of the instructions on the time series, not the whole
    %   thing.
    
    properties
        start_datetime
        start_offset = 0 %(s)
        dt %seconds
        n_samples
        %units_use
    end
    
    properties (Dependent)
        fs
        end_time
        start_time
    end
    
    methods
        function value = get.fs(obj)
            value = 1/obj.dt;
        end
        function value = get.end_time(obj)
            value = obj.start_offset + (obj.n_samples-1)*obj.dt;
        end
        function value = get.start_time(obj)
            value = obj.start_offset;
        end
    end
    
    methods
        function obj = time(dt,n_samples)
            %
            %   obj = sci.time_series.time(dt,n_samples)
            obj.dt = dt;
            obj.n_samples = n_samples;
        end
        function time_array = getTimeArray(obj)
            %Creates the full time array.
            %
            %    In general this should be avoided if possible ...
            
            time_array = (0:obj.n_samples-1)*obj.dt + obj.start_offset;
        end
        function times = getTimesFromIndices(obj,indices)
            times = obj.start_offset + (indices-1)*obj.dt;
        end
        %TODO: Provide interpolation indices function - ???? What does this mean????
        function indices = getNearestIndices(obj,times)
            indices = round((times - obj.start_offset)./obj.dt)+1;
        end
    end
    
end

