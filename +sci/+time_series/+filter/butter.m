classdef butter < handle
    %
    %   Class:
    %   sci.time_series.filter.butter
    %
    %   A Butterworth filter is maximially flat in the pass band with the
    %   trade off of not being very steep in transition, thus typically
    %   requiring a higher order filter.
    %
    %   Filter ToDos:
    %   - get coefficients
    %
    %   See Also:
    %   sci.time_series.data_filterer
    %   sci.time_series.filter.smoothing
    
    properties
        %-----------------------
        order   %Filter order
        cutoff_or_cutoffs
        type
        zero_phase %logical
    end
    
    methods
        function obj = butter(order,cutoff_or_cutoffs,type,varargin)
            %x
            %
            %   obj = butter(order,cutoff_or_cutoffs,type,varargin)
            %
            %   Inputs:
            %   -------
            %   order : number
            %       The order of the filter. Higher orders lead to ... (JAH
            %       TODO: finish description)
            %
            %   cutoff_or_cutoffs :
            %       The frequency bands to cutoff at, in Hz.
            %
            %   type : {'low','high','stop','pass'}
            %
            %   Optional Parameters:
            %   --------------------
            %   zero_phase : (default true)
            %       If true, the function filtfilt is used.
            %
            %   Examples:
            %   ---------
            %   f = sci.time_series.filter.butter(3,100,'low','zero_phase');
            %   f = sci.time_series.filter.butter(2,100,'low');
            %   f = sci.time_series.filter.butter(1,10,'high');
            %   f = sci.time_series.filter.butter(1,[300 3000],'pass');
            %   f = sci.time_series.filter.butter(2,[55 65],'stop');
            %
            
            in.zero_phase = true;
            in = sl.in.processVarargin(in,varargin);
            
            obj.order  = order;
            
            if strcmp(type,'pass') || strcmp(type,'band')
                type = 'bandpass';
            end
            
            obj.type   = type;
            obj.zero_phase = in.zero_phase;
            obj.cutoff_or_cutoffs = cutoff_or_cutoffs;
        end
        function data = filter(obj,data,fs)
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
               filter_method = @sl.array.mex_filtfilt;
            else
               filter_method = @sl.array.mex_filter;
            end
            
            data = filter_method(B,A,data);
        end
        function [B,A] = getCoefficients(obj,fs)
            %x Compute the coefficients
            %
            %    Inputs:
            %    -------
            %    fs : scalar
            %        Sampling rate
            %
            [B,A] = butter(obj.order,obj.cutoff_or_cutoffs/(fs/2),obj.type);
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
            %
            %   str = getSummaryString(obj,fs)
            %   
            %   TODO: We don't need fs, we should
            %   remove it as a requirement - need to update filter caller
            %   from time_series.data
            
            if obj.zero_phase
                filter_method = 'filtfilt()';
            else
                filter_method = 'filter()';
            end
            
            freq_values = obj.cutoff_or_cutoffs;
            switch obj.type
                case 'low'
                    filter_type = 'low pass';
                    freq_str = sprintf('%g',freq_values);
                case 'high'
                    filter_type = 'high pass';
                    freq_str = sprintf('%g',freq_values);
                case 'bandpass'
                    filter_type = 'band pass';
                    freq_str = sprintf('from %g to %g',freq_values(1),freq_values(2));
                case 'stop'
                    filter_type = 'band_stop';
                    freq_str = sprintf('from %g to %g',freq_values(1),freq_values(2));
            end
            
            str = sprintf('Butterworth Filter: type: %s,  frequency: %s,  order: %d,  method: %s',filter_type,freq_str,obj.order,filter_method);
        end
        function flag = isequal(o1,o2)
            %
            %
            %   Example
            %   -------
            %   o1 = sci.time_series.filter.butter(2,5,'low');
            %   o2 = sci.time_series.filter.butter(2,5,'low');
            %   o3 = sci.time_series.filter.butter(2,5,'high');
            %   disp(isequal(o1,o2))
            %   disp(isequal(o1,o3))
            
            flag = strcmp(class(o1),class(o2)) && ...
                    isequal(o1.order,o2.order) && ...
                    isequal(o1.cutoff_or_cutoffs,o2.cutoff_or_cutoffs) && ...
                    isequal(o1.type,o2.type) && ...
                    isequal(o1.zero_phase,o2.zero_phase);

        end
        function disp(obj)
            %            fprintf('xxxxxxx\n')
            %            fprintf(inputname(1))
            %            fprintf('xxxxxxx\n')
            sl.obj.dispObject_v1(obj)
        end
    end
end

