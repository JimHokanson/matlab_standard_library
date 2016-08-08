classdef spectrogram_data < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.spectrogram_data;
    %
    %
    %   Improvements:
    %   -------------
    %   1) Could add on properties for power and magnitude
    
    properties
        original_data %sci.time_series.data
        %
        s %[frequency x time]
        %Complex frequency response
        f
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
           %    Improvements:
           %    -------------
           %    1) Could respect the time units in the time
           %    object of the data
           
           %in = sl.in.processVarargin(in,varargin);

           x = obj.t + obj.original_data.time.start_time;
           y = obj.f;
           imagesc(x,y,abs(obj.s))
           set(gca,'ydir','normal')
        end
    end
    
end

