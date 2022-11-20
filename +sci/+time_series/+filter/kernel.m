classdef kernel < handle
    %
    %   Class:
    %   sci.time_series.filter.kernel
    %
    %   This might be better as "kernal" filtering ...
    %
    %   Filters data with either:
    %   - triangular window
    %   - rectangular window
    %   - gaussian window
    %
    
    
    properties
        window_type     %{'tri','rect','gaussian'}
        width_type      %{'seconds','samples'}
        width_value
        gauss_alpha     %inverse of standard deviation
        zero_phase %logical, if true filtfilt is used instead of filter()
    end
    
    methods
        function set.window_type(obj,value)
            %
            if ~any(strcmp(value,{'rect','tri','gaussian'}))
                error('Unrecognized filter type')
            end
            obj.window_type = value;
        end
    end
    
    methods
        function obj = smoothing(width,varargin)
            %
            %   obj = sci.time_series.filter.smoothing(width,varargin)
            %
            %   Inputs:
            %   -------
            %   width : number
            %       This value is either in samples or seconds, depending
            %       upon the 'width_type' parameter.
            %
            %
            %   Optional Inputs:
            %   ----------------
            %   type : {'tri','rect'} (default 'tri')
            %       The shape to use for smoothing ...
            %       'tri' - triangular window
            %       'rect' - rectangular window
            %   width_type : {'seconds','samples'} (default 'seconds')
            %       Units of the width
            %   zero_phase : logical (default true)
            %       If true the data are filtered forwards and backwards
            %       using filtfilt() instead of filter()
            %   gauss_alpha : default 2.5
            %       The default #
            %
            %   Examples:
            %   ---------
            %   Create a rectangular filter of width 100 samples
            %   obj = sci.time_series.filter.smoothing(100,'type','rect','width_type','samples')
            
            in.type = 'tri';
            in.width_type = 'seconds';
            in.zero_phase = true;
            in.gauss_alpha = 2.5;
            in = sl.in.processVarargin(in,varargin);
            
            obj.window_type = in.type;
            obj.width_type  = in.width_type;
            obj.width_value = width;
            obj.zero_phase  = in.zero_phase;
            
        end
        function width = getWidthInSamples(obj,fs)
            if strcmp(obj.width_type,'samples')
                width = obj.width_value;
            else
                width = ceil(obj.width_value*fs);
            end
        end
        function [B,A] = getCoefficients(obj,fs)
            %
            %   [B,A] = getCoefficients(obj,fs)
            %
            
            A = 1;
            
            samples_width = obj.getWidthInSamples(fs);
            switch lower(obj.window_type)
                case 'rect'
                    B = ones(1,samples_width);
                    B = B./samples_width;
                case 'tri'
                    n = samples_width;
                    %triangle
                    if rem(n,2)
                        %odd
                        w = 2*(1:(n+1)/2)/(n+1);
                        B = [w w((n-1)/2:-1:1)];
                    else
                        %even
                        w = (2*(1:(n+1)/2)-1)/n;
                        B = [w w(n/2:-1:1)];
                    end
                    B = B./sum(B);
                case 'gaussian'
                    
                    
                    
                    N = absolute_data.ftime.durationToNSamples(in.convolve_width);

                    %gausswin
                    alpha = obj.gauss_alpha;
                    L = N-1;
                    n = (0:L)-L/2;
                    w = exp(-(1/2)*(alpha*n/(L/2)).^2);
                    B = w./sum(w);
                    
                    %{
                    
                    N2 = N-1;
                    x = (0:N2)-N2/2;
                    c = -0.5/(sigma^2);
                    filter_kernel = exp(c*x^2);
                    B = filter_kernel./sum(filter_kernel);
                    %}

                    
                    
                    
            end
        end
        function data = filter(obj,data,fs)
            
            A = 1;
            B = obj.getCoefficients(fs);
            
            if obj.zero_phase
                filter_method = @sl.array.mex_filtfilt;
            else
                filter_method = @sl.array.mex_filter;
            end
            
            data = filter_method(B,A,data);
        end
        function plotFrequencyResponse(obj,fs,varargin)
            %
            %
            %  plotFrequencyResponse(obj,fs,varargin)
            %
            %  Optional Inputs:
            %  ----------------
            %
            %  See Also:
            %  freqz
            
            in.N = 1024;
            in = sl.in.processVarargin(in,varargin);
            
            [B,A] = getCoefficients(obj,fs);
            
            [H,F] = freqz(B,A,in.N,fs);
            
            plot(F,abs(H))
        end
        function str = getSummaryString(obj,fs)
            %x Returns a string that summarizes the details of the filter
            %
            %   str = getSummaryString(obj,*fs)
            %
            %
            %
            time_str = sprintf('%g %s',obj.width_value,obj.width_type);
            
            if strcmp(obj.width_type,'samples') && exist('fs','var')
                width_in_seconds = obj.width_value/fs;
                time_str = sprintf('%s (%gs)',time_str,width_in_seconds);
            end
            
            switch obj.window_type
                case 'tri'
                    window_name = 'triangular';
                case 'rect'
                    window_name = 'rectangular';
                otherwise
                    error('Unexpected window type')
            end
            
            if obj.zero_phase
                filter_method = 'filtfilt()';
            else
                filter_method = 'filter()';
            end
            
            str = sprintf('Smoothing filter: %s window, width: %s, method: %s',window_name,time_str,filter_method);
        end
    end
    
end

