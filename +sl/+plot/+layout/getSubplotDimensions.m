function [n_rows,n_columns] = getSubplotDimensions(n_graphs,height_width_ratio,monitor_use)
%monitor_use  Returns the # of rows & columns to use
%
%   This function tries to find the best # of rows & columns to use so as
%   to maximize the plot size, given the size of the monitor
%
%   [nRows,nColumns] = sl.plot.layout.getSubplotDimensions(n_graphs,*height_width_ratio,*monitor_use)
%
%   OUTPUTS
%   ========================================
%   nRows    - # of rows to use for subplot
%   nColumns - # of columns to use in subplot
%
%   INPUTS
%   =========================================
%   n_graphs          - The # of graphs that you have to plot
%   height_width_ratio - (default 1) the ratio of the desired plot 
%                      (height/width), i.e. if you want something that is
%                       twice as high as wide, then use 2.  If you want
%                       something that is twice as wide as tall, then use
%                       1/2.  NOTE: This does not enforce this ratio, but
%                       uses it to find the best rows &columns.
%   monitor_use       - (default 1), if -1 then the monitor size is not used
%                       in the calculation
%
%   POSSIBLE IMPROVEMENTS
%   ===============================
%   Might want something that takes into account a factor that favors
%   non-empty grids (i.e. a 5 x 1 might be better than a 3 x 2 which has 
%   an empty plot) 
%
%   See Also:
%   sl.os.getScreenSize

if nargin < 2 || isempty(height_width_ratio)
    height_width_ratio = 1;
end

if nargin < 3 || isempty(monitor_use)
   monitor_use = 1; 
end

sz = sl.os.getScreenSize(monitor_use,false);
height = sz(4);
width  = sz(3);


rowsCols = zeros(2*n_graphs,2);
curEntryCount = 0;
for iSize = 1:n_graphs
   otherNumber = ceil(n_graphs/iSize);
   rowsCols(curEntryCount+1,:) = [iSize otherNumber];
   rowsCols(curEntryCount+2,:) = [otherNumber iSize];
   curEntryCount = curEntryCount + 2;
end


%COLUMN 1 rows
%COLUMN 2 columns

hRelative = rowsCols(:,1)*height_width_ratio;
wRelative = rowsCols(:,2);

%hRelative : think of this as the total # of pixels we have in height
%wRelative : "   " width

pixH = hRelative/height;
pixW = wRelative/width;

%The best option to use is the one that has the minimum value of the
%largest dimension of H & W

maxDim = max(pixH,pixW);
[~,option] = min(maxDim);

n_rows    = rowsCols(option,1);
n_columns = rowsCols(option,2);

end