classdef smoothing < handle
    %
    %   Class:
    %   sci.time_series.filter.smoothing
    %
    %   This might be better as "kernal" filtering ...
    
    
    properties
        window_type
        width_type
        width_value
        zero_phase %logical
    end
    
    methods
        function set.window_type(obj,value)
            %
            if ~any(strcmp(value,{'rect','tri'}))
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
            %   type : {'tri','rect'}
            %       The shape to use for smoothing ...
            %       tri - triangular window
            %       rect - rectangular window
            %   width_type : {'seconds','samples'}
            %   zero_phase : logical (default true)
            %       If true the data are filtered forwards and backwards
            %       using filtfilt() instead of filter()
            
            in.type = 'tri';
            in.width_type = 'seconds';
            in.zero_phase = true;
            in = sl.in.processVarargin(in,varargin);
            
            obj.window_type = in.type;
            obj.width_type  = in.width_type;
            obj.width_value = width;
            
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
            if strcmp(obj.window_type,'rect')
                B = ones(1,samples_width);
                B = B./samples_width;
            else
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
            end
        end
        function data_out = filter(obj,data_in,fs)
            
            A = 1;
            B = obj.getCoefficients(fs);
            
            if obj.zero_phase
                filter_method = @filtfilt;
            else
                filter_method = @filter;
            end
            
            data_out = filter_method(B,A,data_in);
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
           switch obj.window_type
               case 'tri'
                   window_name = 'triangular';
               case 'rect'
                   window_name = 'rectangular';
               otherwise
                   error('Unexpected window type')
           end
           
           %TODO: Add on width information ...
           
           str = sprintf('Filtered using a %s window',window_name);
        end
    end
    
end

