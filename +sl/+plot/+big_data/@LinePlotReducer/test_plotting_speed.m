function test_plotting_speed(varargin)
%
%   sl.plot.big_data.LinePlotReducer.test_plotting_speed
%   
%
%   This command is useful for testing 

N = 1e7; %10 million
data = rand(N,1);

t1 = h__doPlotting(N,data);
%t2 = h__doPlotting(N,data,'use_time_object',false);

fprintf('Time 1: %0.2g - using time object\n',t1);
%fprintf('Time 2: %0.2g - without time object\n',t2);


end

function t = h__doPlotting(N,data,varargin)
in.use_time_object = true;
in = sl.in.processVarargin(in,varargin);



if in.use_time_object
    t = sci.time_series.time(1,length(data));
else
    t = 1:N;
end

h = sl.plot.big_data.LinePlotReducer(t,data);

h.renderData()

profile on
tic
for i = 1:100
    if mod(i,2)
        set(gca,'xlim',[0 1000])
    else
        set(gca,'xlim',[0 N])
    end
end
t = toc;
profile off

end