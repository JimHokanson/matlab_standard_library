function adjustTextLabels(ax)
%
%   sl.plot.postp.adjustTextLabels
%
%   Move text boxes to bottom of graph

h_text = findobj(ax.Children,'Type','Text');

y_lim = ax.YLim;

for i = 1:length(h_text)
   h_text(i).Position(2) = y_lim(1); 
end

end