classdef tests_data
    %
    %   Class:
    %   sci.time_series.tests_data
    
    properties
    end
    
    methods
        function testPlotting()
            t = linspace(-5,5,1e7);
            y1 = abs(log(sinc(t)));
            d1 = sci.time_series.data(y1,1);
            
            t = linspace(-5,5,1e8);
            y2 = abs(log(sinc(t)));
            d2 = sci.time_series.data(y2,1);
            
            %{
            plot(d1)
            plot(d2)
            %}
        end
    end
    
end

