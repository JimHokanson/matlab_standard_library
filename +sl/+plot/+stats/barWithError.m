function s = barWithError(data,varargin)
%
%   s = sl.plot.stats.barWithError(data,varargin)
%
%   Inputs
%   ------
%   data: cell or matrix
%       cell - each index is a vector of data
%       matrix - each column is a vector of data
%
%   Outputs
%   -------
%   s: struct
%       .n_per_bar
%       .y_bar - average values 
%       .h_bar - bar handles
%       .h_error - sl.plot.stats.error_bars

%{
s = sl.plot.stats.barWithError({bc_saline bc_pge2},'labels',{'Saline','PGE2'},'colors',{[12 114 186]./255,[181 37 36]./255})

%}

%in.allow_nan = true <= is this how we want to handle NaN?

in.labels = {};
in.colors = []; %TODO: provide expansion to cell array form 'rgb' => {'r' 'g' 'b'} [1 0 1; 1 1 0] {[1 0 1] [1 1 0]}
in.error_type = 'sem';
in.add_n = true;
in.fontsize = 16; %Note, the user can do this relatively easy, but 
%it is 1 less step for the user (if the default is reasonable)
in = sl.in.processVarargin(in,varargin);

s = struct;

%Computing data values
%--------------------------------------------------------------------------
%Use sl.stats.nan_stats.sem instead ...
if iscell(data)
    n_bars = length(data);
    n_per_bar = cellfun(@(x) sum(~isnan(x)),data);
    y_bar = cellfun(@nanmean,data);
    switch in.error_type
        case 'sem'
            l_error = cellfun(@(x,y) nanstd(x)/sqrt(y),data,num2cell(n_per_bar));
            h_error = l_error;
        otherwise
            error('Option not yet implemented')
    end
else
    n_bars = size(data,2);
    n_per_bar = sum(~isnan(data),1);
    y_bar = nanmean(data,2);
    switch in.error_type
        case 'sem'
            l_error = std(data,0,1)./sqrt(n_per_bar);
            h_error = l_error;
        otherwise
            error('Option not yet implemented')
    end
end

s.n_per_bar = n_per_bar;
s.y_bar = y_bar;

%Rendering
%--------------------------------------------------------------------------
% s.h_bar = bar(y_bar);
h_bar = zeros(1,n_bars);

if ~ishold
    cla
end

hold on
for iBar = 1:n_bars
   h_bar(iBar) = bar(iBar,y_bar(iBar)); 
end
s.h_bar = h_bar;

s.h_error = sl.plot.stats.error_bars(1:n_bars,y_bar,l_error,h_error,'bar_options',{'linewidth',2,'color','k'});
hold off

%Post-processing
%--------------------------------------------------------------------------
%This may change ...
ax = gca();
 
xlim = get(ax,'xlim');
x_diff = diff(xlim);
xlim(1) = xlim(1) - 0.1*x_diff;
xlim(2) = xlim(2) + 0.1*x_diff;
set(ax,'xlim',xlim);

set(ax,'xtick',1:n_bars,'FontSize',in.fontsize);

if ~isempty(in.labels)
    set(ax,'xticklabels',in.labels);
end

if in.add_n
    x_tick_labels = get(ax,'xticklabels');
    x_tick_labels = cellfun(@(x,y) sprintf('%s (n = %d)',x,y),h__row(x_tick_labels),h__row(num2cell(n_per_bar)),'un',0);
    set(ax,'xticklabels',x_tick_labels);
end

if ~isempty(in.colors)
    for iBar = 1:n_bars
       set(s.h_bar(iBar),'facecolor',in.colors{iBar}); 
    end
end

end

function x = h__row(x)
    if size(x,2) > 1
        x = x';
    end
end
