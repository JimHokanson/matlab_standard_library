classdef butter
    %
    %   Class:
    %   sci.time_series.filter.butter
    %   
    %   A Butterworth filter is maximially flat in the pass band with the 
    %   trade off of not being very steep in transition, thus typically
    %   requiring a higher order filter ...
    %
    %   TODO: Decide on an interface that these things must have for
    %   actually filtering the data ...
    %   
    %   Filter ToDos:
    %   - plot filter response
    %   - create filter display string
    %   - get coefficients
    %
    %   See Also:
    %   sci.time_series.data_filterer
    
    properties
       %-----------------------
       order   %Filter order
       cutoff_or_cutoffs
       type
       zero_phase %logical
    end
    
    methods
        function obj = butter(order,cutoff_or_cutoffs,type,varargin)
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
            %   zero_phase : 
            
           in.zero_phase = true;
           in = sl.in.processVarargin(in,varargin);
           
           obj.order  = order;
           
           if strcmp(type,'pass')
               type = 'bandpass';
           end
           
           obj.type   = type;
           obj.zero_phase = in.zero_phase;
           obj.cutoff_or_cutoffs = cutoff_or_cutoffs;
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
        function disp(obj)
%            fprintf('xxxxxxx\n')
%            fprintf(inputname(1))
%            fprintf('xxxxxxx\n') 
           sl.obj.dispObject_v1(obj) 
        end
    end
end

