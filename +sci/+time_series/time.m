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
        start_datetime %This isn't really being used currently.
        
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
        function obj = time(dt,n_samples,varargin)
            %
            %   obj = sci.time_series.time(dt,n_samples)
            %
            %   Optional Inputs:
            %   ----------------
            %   start_offset:
            %
            %   See Also:
            %   sci.time_series.time.getNewTimeForDataSubset
            
            %TODO: Document these optional inputs
            %sample_offset - for when the
            in.start_offset = [];
            in.sample_offset = [];
            in = sl.in.processVarargin(in,varargin);
            
            %TODO: I think I'd like to clean this up ...
            if ~isempty(in.sample_offset)
                obj.start_offset = dt*(in.sample_offset-1);
            elseif ~isempty(in.start_offset)
                obj.start_offset = in.start_offset;
            else
                obj.start_offset = 0;
            end
            
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
            %x Given sample indices return times of these indices (in seconds)
            %
            %    This is useful for plotting when we need to go from an
            %    abstract representation of the time to actual time values
            %    that are associated with each data point. NOTE: Ideally
            %    plotting functions would actually support this abstract
            %    notion of time as well.
            %
            %    Inputs:
            %    -------
            %    indices:
            %        Indices into the "time array". An input value of 1 will
            %        return a value of the start_offset and a value of 2
            %        will represent a value of the start_offset + dt.
            %
            %
            times = obj.start_offset + (indices-1)*obj.dt;
        end
        
        %TODO: Provide interpolation indices function - ???? What does this mean????
        
        function [indices,time_errors] = getNearestIndices(obj,times)
            %
            %   TODO: Document ...
            %   
            %   Inputs:
            %   -------
            %   times:
            %
            %   Outputs:
            %   --------
            %   indices:
            %   time_errors:
            
            raw_indices = (times - obj.start_offset)./obj.dt;
            indices = round(raw_indices)+1;
            if nargout == 2
                time_errors = (indices - (raw_indices + 1))*obj.dt;
            end
        end
    end
    
    %Construction methods -------------------------------------------------
    methods
        function new_time_object = getNewTimeObjectForDataSubset(obj,new_start_time,n_samples)
            %
            %   new_time_object = obj.getNewTimeObjectForDataSubset(new_start_time,n_samples)
            %
            new_time_object = sci.time_series.time(...
                obj.dt,n_samples,...
                'start_offset',new_start_time);
        end
    end
    
end

