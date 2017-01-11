function s = linePlotByObservation(data,varargin)
%
%   s = sl.plot.stats.linePlotByObservation(data,varargin)
%   
%   Inputs
%   ------
%   data: cell array of vectors
%
%   TODO: Finish this function
%
%   Goal is to plot each data point across the different conditions

in.labels = {};
in = sl.in.processVarargin(in,varargin);

s = struct;

merged = vertcat(data{:});

plot(merged,'k')
set(gca,'xlim',[0.8 2.2],'FontSize',16)
set(gca,'xtick',[1 2],'xticklabel',{'saline','pge2'})



end