function result = boxPlot(x_data,varargin)
%x Wrapper for boxplot to make it more fun to use!
%
%   result = sl.plot.stats.boxPlot(x_matrix,varargin)
%   
%   result = sl.plot.stats.boxPlot(x_cells,varargin)
%   
%   Outputs
%   -------
%   result : sl.plot.stats.results.box_plot_result
%
%
%
%   Inputs
%   ---------
%   x_matrix : [observations x types]   
%      
%   x_cells : NYI
%       See 'group_type' parameter
%
%
%
%   Optional Inputs - Any options from boxplot and:
%   ------------------------------------------------
%   group_type : default 'merge'
%       - 'merge' - all one big group 
%       - 'separate' - NYI each cell in its own group x x x  y y y  z z z
%       - 'interleaved' - indices of each group together x1 y1 z1  x2 y2 z2
%
%   See Also
%   ---------
%   boxplot
%
%
%   Examples
%   --------
%   TODO!!!   
%
%
%
%
%
%
%   Improvements
%   -------------------------------------------
%   1) Add on default options for looks

in.x = []; %Only for regular box plot

in.labels = [];
in.add_n = true;
in.dx = 1;
in.dx_group = 1.5;
in.group_id = 1;
in.group_type = 'merge';
[in,varargin] = sl.in.processVararginWithRemainder(in,varargin);

if iscell(x_data)
    
    if ~isempty(in.labels)
        if length(in.labels) ~= length(x_data)
            error('Size of labels must equal the # of cells in the input')
        end
    end
    
    cur_data = x_data{1};
    
     if isempty(in.labels)
        cur_label = {};
     else
     	cur_label = in.labels{1};
     end
    
    result = sl.plot.stats.boxPlot(cur_data,varargin{:},...
        'labels',cur_label,...
        'add_n',in.add_n);
    for i = 2:length(x_data)
        if strcmp(in.group_type,'merge')
            group_id = 1;
        else
            group_id = i;
        end
        if isempty(in.labels)
            cur_label = [];
        else
            cur_label = in.labels{i};
        end
        result.addData(x_data{i},'group_id',group_id,...
            'labels',cur_label,...
            'add_n',in.add_n);
    end
            
    switch lower(in.group_type)
        case 'interleaved'
            result.entries.interleaveGroups('dx',in.dx,'dx_group',in.dx_group);
        case 'separate'
            %TODO: NYI
        case 'merge'
        otherwise
            error('Unrecognized group type: %s',in.group_type)
    end
    
else
    %Matrix data ...
    %This removes any labels ...
    h = boxplot(x_data,varargin{:});
    n_boxes = size(h,2);
    temp = cell(1,n_boxes);
    for i = 1:n_boxes
        if isempty(in.labels)
            cur_label = '';
        else
            cur_label = in.labels{i};
        end
        if isempty(in.x)
            cur_x = [];
        else
            cur_x = in.x(i);
        end
        temp{i} = sl.plot.stats.results.box_plot_entry(...
            gca,h(:,i),x_data(:,i),'group_id',in.group_id,...
            'label',cur_label,'add_n',in.add_n,'x',cur_x);
    end
    entries = [temp{:}];
    result = sl.plot.stats.results.box_plot_result(gca,entries);
end

%Add on option to save as SVG
sl.plot.uimenu.addExportSVGOption(gcf)


end