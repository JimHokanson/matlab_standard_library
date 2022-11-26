classdef spectrogram_data < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.spectrogram_data;
    %
    %   See Also
    %   --------
    %   sci.time_series.spectrogram_calculators
    %
    %
    %   Improvements:
    %   -------------
    %   1) Could add on properties for power and magnitude
    
    properties
        original_data %sci.time_series.data
        %
        
        
        %[frequency x time]
        %Complex frequency response
        s
        
        %frequency array
        f
        
        %time array
        t
    end
    
    methods
        function obj = spectrogram_data(s,f,t,data)
            %
            %   Inputs:
            %   --------
            obj.original_data = data;
            obj.s = s;
            obj.f = f;
            obj.t = t;
        end
        function plot(obj)
            %
            %
            %   Improvements:
            %   -------------
            %   1) Could respect the time units in the time
            %   object of the data
            %
            %   Examples
            %   --------
            %   d = sci.time_series.data.example(1);
            %   window_width = 0.5;
            %   r = obj.calculators.spectrogram.ml_spectrogram(d,window_width);
            
            
            %in = sl.in.processVarargin(in,varargin);
            
            x = obj.t;
            y = obj.f;
            imagesc(x,y,abs(obj.s))
            set(gca,'ydir','normal')
            xlabel('time (s)')
            ylabel('Frequency (Hz)')
            h = colorbar();
            ylabel(h,'Power/Frequency (dB/Hz)');
        end
    end
    
end

