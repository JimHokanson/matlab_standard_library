classdef ellip
    % Project 1 creating a ellip filter, a signal processing filter that
    % adjusts ripple in both stopband and passband
    % Filter DOs=
    %  -plot filter results
    %  -create filter display screen
    %  -get coefficients
    % See also:
    % sci.time_series.data_butter or
    % sci.time_series.data_filterer
    
    properties
        % outputs order, cutoff_or_cutoffs, type of filter, and zero phase(???)
        order % filter order
        cutoff_or_cutoffs
        type
        passband_peak_to_peak_db % Amplitude of pass band
        stopband_attenuation % Amplitude of stop band
        zero_phase
    end
    methods
        function obj = ellip(order, passband_peak_to_peak_db, stopband_attenuation, cutoff_or_cutoffs, type, varargin)
            % Inputs defined
            % Order = order number of filter
            % Storing order, type, cutoof_or_cutoffs in a function handle
            
            obj.order = order;
            obj.type = type;
            obj.cutoff_or_cutoffs= cutoff_or_cutoffs;
            obj.passband_peak_to_peak_db= passband_peak_to_peak_db;
            obj.stopband_attenuation= stopband_attenuation;
        end
        function data_out = filter(obj, data_in, fs) % I'm not sure why I need a sampling frequency
            % I am very unsure about the use of in.zero_phase
            % and the use of this line of code in =
            % sl.in.processVarargin(in,varargin); I guess I have no grip on
            % what zerophase means in regard to filtering.
            % this should clear up nearly everything
            % This is causing an error in the data_in because it is still
            % unsure what in is obviously
            
            
            [B,A] = ellip(obj.order, obj. obj.passband_peak_to_peak_db, obj.stopband_attenuation,obj.cutoff_or_cutoffs, obj.type);
            
            if obj.zero_phase
                filter_method = @filtfilt;
            else
                filter_method = @filter;
            end
            data_out = filter_method(B,A,data_in);
            
            
        end
    end
end



