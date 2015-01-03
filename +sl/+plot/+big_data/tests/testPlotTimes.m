function testPlotTimes
%
%   Results:
%   No incrase in time is seen until 1e6

%????
%1) How does this compare for random data instead of a straight line?
%2) What happens if we input x values????
%

%Note that plotting is a non-blocking call, so we need to ...



%Initialize data
%----------------
n_plots = 8;
n_runs = 10;
all_data  = cell(1,n_plots);
all_times = zeros(1,n_plots);
for iData = 1:length(all_data)
   all_data{iData} = 1:(1*10^iData); 
end

for iPlot = 1:n_plots
tic;
for iRun = 1:n_runs
    close all
    plot(all_data{iPlot});
    drawnow
end
all_times(iPlot) = toc/n_runs;
end

keyboard

subplot(2,1,1)
plot(1:8,all_times,'o-','Linewidth',2);
set(gca,'FontSize',18)
xlabel('n samples log10 scale')
ylabel('Execution time per plot (s)')
subplot(2,1,2)

plot(1*10.^(1:8),all_times,'o-','Linewidth',2);
set(gca,'FontSize',18)
xlabel('n samples')
ylabel('Execution time per plot (s)')