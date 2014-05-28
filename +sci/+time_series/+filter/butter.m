classdef butter < sci.time_series.filter
    %
    %   Class:
    %   sci.time_series.filter.butter
    %   
    %   TODO: dt should not be a property of this but of the filterer
    %
    %   See Also:
    %   sci.time_series.data_filterer
    
    properties
       %-----------------------
       order   %Filter order
       cutoff_or_cutoffs
       type
       method
    end
    
    methods
        function obj = butter(order,cutoff_or_cutoffs,type,varargin)
            %
            %   Parameters:
            %   -----------  
            %   cutoff_or_cutoffs :
            %       The frequency bands to cutoff at, in Hz.
            %
            %   type : {'low','high','stop','pass'}
            %
            %   Optional Parameters:
            %   --------------------
            %   
            
           in.method = 'filtfilt';
           in = sl.in.processVarargin(in,varargin);
           
           obj.order  = order;
           
           if strcmp(type,'pass')
               type = 'bandpass';
           end
           
           obj.type   = type;
           obj.method = in.method;
           obj.cutoff_or_cutoffs = cutoff_or_cutoffs;
        end
        function data_out = filter(obj,data_in,fs)
            
           %TODO: Check cutoffs vs fs ... 
            
           [B,A] = butter(obj.order,obj.cutoff_or_cutoffs/(fs/2),obj.type);
           
           if ischar(obj.method)
               filter_method = str2func(obj.method);
           else
               filter_method = obj.method;
           end
           
           data_out = filter_method(B,A,data_in);
        end
    end
    
    methods (Static)
        function obj = createLowPassFilter(order,cutoff)
           obj = sci.time_series.filter.butter(order,cutoff,'low');
        end
        function obj = createHighPassFilter(order,cutoff)
           obj = sci.time_series.filter.butter(order,cutoff,'high'); 
        end
        function obj = createBandstopFilter(order,cutoffs)
           obj = sci.time_series.filter.butter(order,cutoffs,'stop'); 
        end
        function obj = createBandPassFilter(order,cutoffs)
           obj = sci.time_series.filter.butter(order,cutoffs,'pass');  
        end
    end
    
end

