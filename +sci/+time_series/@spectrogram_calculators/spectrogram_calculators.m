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
            
            
            [S,F,T] = spectrogram
            
           %TODO: Implement nicer access to spectrogram function 
        end
    end
    
end

