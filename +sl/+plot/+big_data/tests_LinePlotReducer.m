classdef (Hidden) tests_LinePlotReducer
    %
    %   Class:
    %   sl.plot.big_data.tests_LinePlotReducer
    
    %   addpath('D:\Projects\matlab_code_downloaded\LinePlotReducer')
    
    %   JAH: Things to fix:
    %   1) 
    %
    
    %??????
    %I think resizing things previously called a position callback to fire
    %but with normalized units, it doesn't seem to in 2014b
    %
    %What do we listen to? Figure resize?????
    
    properties
    end
    
    methods (Static)
        
        
        %   Types of tests:
        %   ---------------
        %   1) plot(x1,y1)
        %      hold on
        %      plot(x2,y2)
        %      hold off
        %   2) plot(x1,y1,x2,y2) %See test001
        %   3) plot(ax,x1,y1)
        
        function test001_MatrixMultipleInputs()
            t = 1:1e8;
            y = rand(length(t),4);
            y2 = y;
            wtf = sl.plot.big_data.LinePlotReducer(t,4-y,'r',t,y2,'c','Linewidth',2);
            wtf.renderData;
        end
    end
    
end

