classdef (Hidden) tests_LinePlotReducer
    %
    %   Class:
    %   sl.plot.big_data.tests_LinePlotReducer
    
    %   addpath('D:\Projects\matlab_code_downloaded\LinePlotReducer')
    
    %   JAH: Things to fix:
    %
    %   POINTS 1 & 2 are handled (I think) in the resize callback
    %   -------------------------
    %   1) I zoomed in and then zoomed out. On zooming out, I added a bit
    %   more data, which caused a figure resize, which allowed a bit more
    %   data to be added, which caused a figure resize. How do I detect
    %   this and stop it from happening????
    %   
    %   2) Similarly - it doesn't seem like I can zoom out to the original
    %   values. Why is this?
    %   Hypothesis - When zooming out, the data doesn't encompass the
    %   zoomed out size, so the auto resize shrinks it
    %   Setting a line to maximize this space causes a slight toggle
    %   in the x-limit, which is really annoying, since you get
    %   oscillations back and forth.
    %   Count:1 - xlim:[1.4e-06 1e+02] - position:[0.13 0.11 0.78 0.81]
    %   Count:1 - xlim:[0 1e+02] - position:[0.13 0.11 0.78 0.81]
    %   Callback 2 called for: 90090430 at 273.61
    %   Count:1 - xlim:[1.4e-06 1e+02] - position:[0.13 0.11 0.78 0.81]
    %   Count:1 - xlim:[0 1e+02] - position:[0.13 0.11 0.78 0.81]
    %   Callback 2 called for: 90090430 at 273.704
    %   Count:1 - xlim:[1.4e-06 1e+02] - position:[0.13 0.11 0.78 0.81]
    %   Count:1 - xlim:[0 1e+02] - position:[0.13 0.11 0.78 0.81]
    %   Callback 2 called for: 90090430 at 273.766
    %   -------------------------
    %   3) Plotting a new object, what does that do for the old object since 
    %   presumably the listeners still exist.
    
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
        
        function testSpeed()
            
            %sl.plot.big_data.tests_LinePlotReducer.testSpeed
            
            %This tests normal plotting, we need to test the same thing
            %for the LinePlotReducer class
            
            n_samples = [1e5 1e6 1e7 1e8 2e8 3e8];
            
            reps = 10;
            speeds = zeros(reps,length(n_samples));
            
            for iRep = 1:reps
                for iSamples = 1:length(n_samples)
                    cur_n_samples = n_samples(iSamples);
                    tic
                    close all
                    plot(1:cur_n_samples);
                    drawnow %Seems to block execution until the rendering has finished
                    speeds(iRep,iSamples) = toc;
                end
            end
            keyboard
        end
        function test001_MatrixMultipleInputs()
            t = 1:1e8;
            y = rand(length(t),4);
            y2 = y;
            wtf = sl.plot.big_data.LinePlotReducer(t,4-y,'r',t,y2,'c','Linewidth',2);
            wtf.renderData;
        end
        function interestingInput()
           %From FEX: 40790
            n = 1e7 + randi(1000);                          % Number of samples
            t = sort(100*rand(1, n));                       % Non-uniform sampling
            x = [sin(0.10 * t) + 0.05 * randn(1, n); ...
                 cos(0.43 * t) + 0.001 * t .* randn(1, n); ...
                 round(mod(t/10, 5))];
            x(:, t > 40 & t < 50) = 0;                      % Drop a section of data.
            x(randi(numel(x), 1, 20)) = randn(1, 20);       % Emulate spikes.
            
            %TODO: Why do I get the correct orientation when I do this ...
            %I think it should be many channels with only a few samples,
            %where is the correction coming into play???
            wtf = sl.plot.big_data.LinePlotReducer(t,x);
            wtf.renderData;
        end
        %TODO: Add axes that are linked via x
    end
    
end

