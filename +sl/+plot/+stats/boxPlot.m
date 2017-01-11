function boxPlot(x_data,varargin)

error('Not yet implemented')

in.show_mean = true;
in = sl.in.processVarargin();

[merged_data,extras] = sl.array.mergeFromCells(x_data);
boxplot(merged_data,extras.labels,'labels',{'saline','PGE2'});

end