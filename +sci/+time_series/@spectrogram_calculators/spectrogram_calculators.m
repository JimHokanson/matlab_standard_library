classdef spectrogram_calculators
    %
    %   Class:
    %   sci.time_series.spectrogram_calculators
    %
    %   See Also:
    %   sci.time_series.
    
    properties
    end
    
    methods (Static)
        function ml_spectrogram(data_obj,window_width,varargin)
            %
            %
            %   sci.time_series.spectrogram_calculators.ml_spectrogram(data_obj,window_width,varargin)
            %
            %   ml_spectrogram - matlab spectrogram
            %
            %   Inputs:
            %   -------
            %   data_obj : sci.time_series.data
            %   window_width : scalar
            
            in.overlap_time  = [];
            in.overlap_pct   = [];
            in.width_is_time = true;
            in.n_fft         = [];
            in = sl.in.processVarargin(in,varargin);
            
            %Step 1: Determine overlap width
            
            keyboard
            
            x = data_obj.d;
            
            %window - integer
            %
            
            [S,F,T] = spectrogram(x,window,noverlap,nfft,fs);
            
           %TODO: Implement nicer access to spectrogram function 
        end
    end
    
end

