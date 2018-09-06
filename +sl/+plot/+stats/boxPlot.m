function result = boxPlot(x_data,varargin)
%x Wrapper for boxplot to make it more fun to use!
%
%   sl.plot.stats.boxPlot(x_matrix,varargin)
%   
%   sl.plot.stats.boxPlot(x_cells,varargin)
%   
%   Data formats
%   ------------
%   
%
%   Optional Inputs
%   ---------------
%   See boxplot
%
%   See Also
%   ---------
%   boxplot
%
%   Improvements
%   -------------------------------------------
%   1) Add on default options for looks

if iscell(x_data)
    %TODO: Check for vector 
    [merged_data,extras] = sl.array.mergeFromCells(x_data);
    h = boxplot(merged_data,extras.labels,varargin{:});
else
    h = boxplot(x_data,varargin{:});
    n_boxes = size(h,2);
    temp = cell(1,n_boxes);
    for i = 1:n_boxes
        temp{i} = sl.plot.stats.results.box_plot_entry(gca,h(:,i),x_data(:,i));
    end
    entries = [temp{:}];
    result = sl.plot.stats.results.box_plot_result(entries);
end





end