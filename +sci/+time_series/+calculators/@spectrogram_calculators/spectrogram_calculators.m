classdef spectrogram_calculators < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.spectrogram_calculators
    %
    %   Implemented methods
    %   -------------------
    %   sci.time_series.calculators.spectrogram_calculators.ml_spectrogram
    %
    %   Improvements
    %   ------------
    %   1) This doesn't need to be a handle class but sl.obj.display_class
    %   currently inherits from handle
    %   
    %   See Also
    %   --------
    %   sci.time_series.data
    
    properties
    end
    
    methods (Static)
        function spec_data = ml_spectrogram(data_obj,window_width,varargin)
            %X MATLAB spectrogram
            %
            %   sci.time_series.calculators.spectrogram_calculators.ml_spectrogram(data_obj,window_width,varargin)
            %
            %   sci.time_series.calculators.spectrogram_calculators.ml_spectrogram(data_obj,window_width,varargin)
            %
            %   ml_spectrogram - matlab spectrogram
            %
            %   Outputs
            %   -------
            %   spec_data : sci.time_series.calculators.spectrogram.spectrogram_data
            %
            %   Inputs
            %   ------
            %   data_obj : sci.time_series.data
            %   window_width : scalar 
            %       Default units are seconds. Can be changed to samples by
            %       setting optional input 'width_is_time' to false.
            %       Represents how much data should be used in computing
            %       the transform. 
            %
            %   Optional Inputs
            %   ---------------
            %   overlap_time :
            %       Amount of overlap of the data between consecutive
            %       windows, specified in seconds.
            %   overlap_pct : default 50%
            %       "       " specified as fraction (between 0 and 1)
            %   width_is_time : logical (default true)
            %       If true then the 'window_width' is treated as being
            %       specified in seconds. If false, it is treated as
            %       samples.
            %   n_fft :
            %       TODO: Describe default behavior
            %   freq_resolution : 
            %       Specifies the # of samples to use for the FFT so that
            %       the spacing between frequency bins matches the
            %       specified resolution
            %
            %   Examples
            %   --------
            %   d = sci.time_series.data.example(1);
            %   window_width = 0.5;
            %   r = obj.calculators.spectrogram.ml_spectrogram(d,window_width);
            %
            
            in.overlap_time  = [];
            in.overlap_pct   = [];
            in.width_is_time = true;
            in.n_fft         = [];
            in.freq_resolution = [];
            in = sl.in.processVarargin(in,varargin);
            
            DEFAULT_OVERLAP_PCT = 0.50; %50%
            

            %x - the data
            %--------------------
            x = data_obj.d;
            
            %n_windows - integer
            %----------------------------
            data_dt = data_obj.time.dt;
            data_total_time_s = data_obj.time.elapsed_time;           
            n_data_samples = data_obj.n_samples;
            
            %TODO: Add on error checking here
            if in.width_is_time
                n_samples_per_window = round(window_width/data_dt);
            else
                n_samples_per_window = window_width;
            end
                        
            %overlap
            %----------------------------
            if ~isempty(in.overlap_time)
               n_samples_overlap = round(in.overlap_time/data_dt); 
            elseif ~isempty(in.overlap_pct)
               n_samples_overlap = round(n_samples_per_window*in.overlap_pct); 
            else
               n_samples_overlap = round(n_samples_per_window*DEFAULT_OVERLAP_PCT);
            end
            
            %n_fft 
            %------------------------------
            %nfft is the FFT length and is the maximum of 256 or the next power of 
            %2 greater than the length of each segment of x
            if ~isempty(in.n_fft)
                n_fft = in.n_fft;
            elseif ~isempty(in.freq_resolution)
                max_frequency = [];
                n_fft = ceil(max_frequency/in.freq_resolution);
            else
                %use default
                n_fft_p2 = ceil(log2(n_samples_per_window));
                n_fft = max(256,n_fft_p2); 
            end
            
            %fs 
            %-------------------------------
            fs = 1/data_dt;
            
            %    spectrogram(y,kaiser(128,18),120,     128,  1E3,'yaxis');
            %s = spectrogram(X,WINDOW,        NOVERLAP,NFFT, Fs)
            
            [s,f,t] = spectrogram(x,n_samples_per_window,n_samples_overlap,n_fft,fs);
            %
            %t always starts at 0
            
            t = t + data_obj.time.start_offset;
            
            spec_data = sci.time_series.calculators.spectrogram.spectrogram_data(s,f,t,data_obj);            
        end
    end
end

