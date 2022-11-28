classdef median
    %
    %   Class:
    %   sci.time_series.filter.median
    %
    %
    %
    %   This turns out to be EXTREMELY SLOW using medfilt1 as
    %   the underlying implementation. I'm going to hold off on
    %   implementing this for now and use a mean (boxcar) filter instead
    
    properties
       filter_width  %seconds or samples
       width_is_time %clarifies value type of 'filter_width'
    end
    
    methods
        function obj = median(width,varargin)
            %
            
            error('Not yet implemented')
            
            in.width_is_time = true;
            in = sl.in.processVarargin(in,varargin);
            
        end
        function getFilterSampleWidth(obj,fs)
           if obj.width_is_time
               
           else
              n_samples = obj.filter_width; 
           end
        end
        function data_out = filter(obj,data_in,fs)
           %x Filter the data
           %
           %    Inputs:
           %    -------
           %    fs : scalar
           %        Sampling rate
           %
            
           %TODO: Check cutoffs vs fs ... 
            
           [B,A] = obj.getCoefficients(fs);
           
           if obj.zero_phase
               filter_method = @filtfilt;
           else
               filter_method = @filter;
           end
           
           data_out = filter_method(B,A,data_in);
        end
    end
    
end

