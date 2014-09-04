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
        start_datetime %This can be used for real dates to identify the
        %actual time of the first sample. No support for time zones is in
        %place.
        
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
    
    %Dependent Methods ----------------------------------------------------
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
    
    %Constructor Methods --------------------------------------------------
    methods
        function obj = time(dt,n_samples,varargin)
            %
            %   obj = sci.time_series.time(dt,n_samples)
            %
            %   Inputs:
            %   -------
            %   dt : 
            %       Time between sample points.
            %   n_samples : 
            %       # of samples in the data.
            %
            %   Optional Inputs:
            %   ----------------
            %   start_datetime : datenum
            %      Start of the data collection with date and time
            %      information.
            %   start_offset : (default 0)
            %       Normally this will be 0.
            %   sample_offset :
            %       This can be specified instead of "start_offset" in
            %       cases in which it is more natural to specify which
            %       sample is being used.
            %
            %   See Also:
            %   sci.time_series.time.getNewTimeForDataSubset
            
            %TODO: Document these optional inputs
            %sample_offset - for when the
            in.start_datetime = 0;
            in.start_offset = [];
            in.sample_offset = [];
            in = sl.in.processVarargin(in,varargin);
            
            if ~isempty(in.sample_offset)
                if ~isempty(in.start_offset)
                    error('Incorrect function usage, only start_offset or sample_offset may be specified, not both')
                end
                obj.start_offset = dt*(in.sample_offset-1);
            elseif ~isempty(in.start_offset)
                obj.start_offset = in.start_offset;
            else
                obj.start_offset = 0;
            end
            
            obj.start_datetime = in.start_datetime;
            obj.dt = dt;
            obj.n_samples = n_samples;
        end
        function new_obj = copy(obj)
           new_obj = sci.time_series.time(obj.dt,obj.n_samples,...
               'start_datetime',obj.start_datetime,'start_offset',obj.start_offset); 
        end
        function new_time_object = getNewTimeObjectForDataSubset(obj,start_sample,n_samples,varargin)
            %
            %   new_time_object = obj.getNewTimeObjectForDataSubset(new_start_time,n_samples)
            %   
            %   Inputs:
            %   -------
            %   start_sample : 
            %   n_samples : 
            %
            %   Optional Inputs:
            %   ----------------
            %   first_sample_time : default (no change)
            %       The default behavior is to keep the time offset of the 
            %       sample. For example, with a sampling rate of 1 and a 
            %       start offset of 0, the 1st sample occurs at time 2 and
            %       the 2nd sample occurs at time 1. If we get a subset of
            %       data starting with the 2nd sample, the new start offset
            %       will be 1, such that the 2nd sample (now 1st) still
            %       occurs at time t = 1
            %
            %   
            %       
            %   
            %   What does this do?????
            
            in.first_sample_time = [];
            in = sl.in.processVarargin(in,varargin);
            
            first_sample_real_time = (start_sample-1)*obj.dt + obj.start_offset;
            
            if isempty(in.first_sample_time)
                start_offset = first_sample_real_time; %#ok<PROP>
                start_datetime = obj.start_datetime; %#ok<PROP>
            else
                start_offset = in.first_sample_time; %#ok<PROP>
                time_change = first_sample_real_time - start_offset;%#ok<PROP>
                start_datetime = obj.start_datetime + time_change;%#ok<PROP>
            end
            
            new_time_object = sci.time_series.time(...
                obj.dt,n_samples,...
                'start_offset',start_offset,... %#ok<PROP>
                'start_datetime',start_datetime);%#ok<PROP>
        end
    end

    methods
        function shiftStartTime(obj,)
            
        end
    end
    
    methods
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
            %   indices :
            %   time_errors :
            
            raw_indices = (times - obj.start_offset)./obj.dt;
            indices = round(raw_indices)+1;
            if nargout == 2
                time_errors = (indices - (raw_indices + 1))*obj.dt;
            end
        end
    end
    
    methods
        
    end
    
end

