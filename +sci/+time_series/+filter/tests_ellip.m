classdef tests_ellip
    %
    %   Class:
    %   sci.time_series.filter.tests_ellip
    
    properties
    end
    
    methods (Static)
        function awesome_test(fs,numsec,f1,f2)
            %
            %   sci.time_series.filter.tests_ellip.awesome_test(fs,numsec,tone_freq1,tone_freq2)
            %
            %   Example:
            %   sci.time_series.filter.tests_ellip.awesome_test(1000,2,20,60)
            
            %{
            fs = 1000;
            numsec = 2;
            f1 = 20;
            f2 = 60;
            %}
            
            %% Generated
%             fs = input('sampling rate'); %(sampling rate)
%             numsec= input('number of seconds'); %(number of sec)
%             tone_freq1= input('tone frequency 1');
%             tone_freq2= input('tone frequency 2');
            
            t = 0:1/fs:numsec;
            w1 = 2*pi*f1;
            w2 = 2*pi*f2;
            %y = sin(wt+p)
            %w = 2*pi*fs

            y1 = sin(w1*t);
            y2= sin(w2*t);
            
            
            figure(1);
            clf;
            
            subplot(2,1,1);
            plot(t, y1, 'k-') % Plot original data
            
            subplot(2,1,2);
            plot(t, y2, 'k-') % plot filtered data
            
            d1 = sci.time_series.data(y1',1/fs);
            
            ellip_filter = asdsadfsdfsdf.ellip(asdfasdfsadfaf);
            ellip_filter.plot(fs)
            plot(ellip_filter,fs)
            
            d1.filter(ellip_filter);
            filtered_data1 = d1.d;
            
        end
    end
    
end

