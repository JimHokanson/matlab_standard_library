classdef (Hidden) tests_data
    %
    %   Class:
    %   sci.time_series.tests_data
    %
    %   See Also:
    %   sci.time_series.data
    %   sl.plot.big_data.LinePlotReducer
    
    properties
    end
    
    methods (Static)
        function testPlotting()
            t = linspace(-5,5,1e7);
            y1 = abs(log(sinc(t)));
            d1 = sci.time_series.data(y1',1);
            
            t = linspace(-5,5,1e8);
            y2 = abs(log(sinc(t)));
            d2 = sci.time_series.data(y2',1);
            
            plot(d1)
            hold all
            plot(d2)
            hold off
        end
        function testChannelCountWarning()
            %This should throw a warning ...
            wtf = sci.time_series.data(rand(1,1e7),0.01);
        end
        function testEventAdding()
            wtf = sci.time_series.data(rand(1e7,1),0.01);
            ev = sci.time_series.discrete_events('test',1:10);
            wtf.addEventElements(ev)
        end
        
    end
end
    
