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
%
%   TODO: Expose those options here
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
%   - merge
%   - separate
%   - interleaved
[in,varargin] = sl.in.processVararginWithRemainder(in,varargin);

if iscell(x_data)
    
    if ~isempty(in.labels)
        %Or for interleaved it is OK to equal the # of columns
        %in cells ...
        
        if strcmp(in.group_type,'interleaved')
            %TODO: We should also support
            if length(in.labels) == length(x_data) && isequal(cellfun('length',in.labels),cellfun('length',x_data))
                %
                %   In this case we have something like:
                %   {{'a' 'b' 'c'},{'a','b','c'}}
                %
                %   We had old code that looked like this
                %Do nothing
            else
                %Here we will assign the same column to each group
                %   {'a' 'b' 'c'} 
                %
                %   -> for 3 groups this becomes
                %   {{'a' 'b' 'c'},{'a' 'b' 'c'},{'a' 'b' 'c'}}
                %   
                %   Note when interleaving we will essentially have:
                %       a,a,a    b,b,b    c,c,c
                
                n_columns = size(x_data{1},2);
                if length(in.labels) ~= n_columns
                    error('Size of labels must equal the # of columns in the input')
                end
                in.labels = repmat({in.labels},1,length(x_data));
            end
        else        
            %I'm not sure this is correct if we are doing merge with multiple
            %columns per cell entry
            if length(in.labels) ~= length(x_data)
                error('Size of labels must equal the # of cells in the input')
            end
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
    
    %This was for a vector passed in as 1xM
    %but we only had one box plot
    if n_boxes ~= size(x_data,2)
        x_data = x_data';
        if n_boxes ~= size(x_data,2)
           error('Unexpected code case') 
        end
    end
    
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
sl.plot.uimenu.addScreenshotOption(gcf)


end