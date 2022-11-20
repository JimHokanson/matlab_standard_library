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
%   Inputs
%   ---------
%   x_matrix : [observations x types]
%
%   x_cells : 
%       See 'group_type' parameter
%
%
%
%   Optional Inputs - Any options from boxplot and:
%   ------------------------------------------------
%   labels :
%          merged:
%               {'g1_1','g1_2','g2_1','g2_2'}
%               {{'g1_1','g1_2'},{'g2_1','g2_2'}}
%
%               TODO: This one is a bit odd, hard to interpret.
%               ?? Have option to add prefix or suffix per group?
%               {'_1','_2'} => {{'_1','_2'},{'_1','_2'}}
%   add_n : default true
%   dx : default 1
%   dx_group : default 1.5
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
%   a = [1 2 2 2 3 3 4 4 5 5;
%        3 4 3 4 5 5 7 8 9 10]';
%   b = 1.3*a + rand(10,2);
%   
%   %1) Just a
%   result = sl.plot.stats.boxPlot(a,'labels',{'control1','test1'})
%
%   %2) a & b
%   result = sl.plot.stats.boxPlot({a,b})
%
%   %3) a & b with various label types
%   result = sl.plot.stats.boxPlot({a,b},'labels',{'control1','test1','control2','test2'})
%   result = sl.plot.stats.boxPlot({a,b},'labels',{{'control1','test1'},{'control2','test2'}})
%   result = sl.plot.stats.boxPlot({a,b},'labels',{'control','test'})
%
%   %4) a & b with interleaving
%   result = sl.plot.stats.boxPlot({a,b},'labels',{'control','test'},'group_type','interleaved')
%
%
%
%
%
%   Improvements
%   -------------------------------------------
%   1) Add on default options for looks
%   2) Add support for group labels
%   3) 
%   
%
%

%{
%%Group labels
figure(1)
clf
plot(1:10)
ax = gca;
n = newline;
ax.XTick      = [2      3           4       6       7           8       10]
ax.XTickLabel = {'2'   ['\newline' '\newline' 'wtf'] '4_4'     '6'    ['\newline' '\newline' 'test'] '8'     '10'}   
xlabel('Best plot ever!!!!!!!!!!!!!!!')
%}

in.g = [];
in.x = []; %Only for regular box plot

in.labels = [];
in.add_n = true;
in.dx = 1;
in.dx_group = 1.5;
in.group_id = 1; %This might be for internal use only ...
%Note, this function is recursive ...
in.group_type = 'merge';
%   - merge
%   - separate
%   - interleaved
[in,varargin] = sl.in.processVararginWithRemainder(in,varargin);

if isvector(x_data)
   if isempty(in.g)
       %do nothing
   else
       [~,ic] = sl.array.uniqueWithGroupIndices(in.g);
       x_data = cellfun(@(x) x_data(x),ic,'un',0);
   end
end

if iscell(x_data)
    
    n_cells = length(x_data);
    n_columns_per_cell = cellfun(@(x) size(x,2),x_data);
    n_columns_total = sum(n_columns_per_cell);

    if ~isempty(in.labels)
        
        n_top_labels = length(in.labels);
        if ischar(in.labels{1})
            n_total_labels = n_top_labels;
        else
            %Assuming we have nested cell-strings
            %We have nested labels, {{'g1','g2','g3},{'g4','g5'}}
            n_total_labels = length([in.labels{:}]);
            n_labels_per_cell = cellfun('length',in.labels);
        end
        
        
        
        %Or for interleaved it is OK to equal the # of columns
        %in cells ...
        
        if strcmp(in.group_type,'interleaved')
            if n_top_labels == n_cells && isequal(n_labels_per_cell,n_columns_per_cell)
                %
                %   In this case we have something like:
                %   {{'a' 'b' 'c'},{'a','b','c'}}
                %
                %   For data like:
                %   {[m x 3],[n x 3]} (2 cells, each with 3 columns)
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
                
                if ~all(n_columns_per_cell == n_columns_per_cell(1))
                    error('All cells must have same # of columns')
                elseif n_columns_per_cell(1) ~= n_top_labels
                    error('# of labels must equal the # of columns in the input')
                end
                
                in.labels = repmat({in.labels},1,n_cells);
            end
        %elseif strcmp(in.group_type,'merge')
        else  
            if n_top_labels == n_columns_total
                %1 for 1
                new_labels = cell(1,n_cells);
                end_I = 0;
                for i = 1:n_cells
                    start_I = end_I + 1;
                    end_I = end_I + n_columns_per_cell(i);
                    new_labels{i} = in.labels(start_I:end_I);
                end
                in.labels = new_labels;
                
                %1 2 3 4 5 6 7
                %1 1 2 3 3 3 3
                %{[1,2],[3],[4,5,6,7])}
            elseif n_cells == n_top_labels
                if n_top_labels == n_total_labels
                    %Replicate for each cell
                    if ~all(n_columns_per_cell == n_columns_per_cell(1))
                        error('All cells must have same # of columns')
                    elseif n_columns_per_cell(1) ~= n_top_labels
                        error('# of labels must equal the # of columns in the input')
                    end
                    
                    in.labels = repmat({in.labels},1,n_cells);
                elseif n_total_labels == n_columns_total
                    %Expecting format like {{'g1','g2'},{'g3','g4','g5}}
                    if ~isequal(n_columns_per_cell,n_labels_per_cell)
                        error('# of columns per cell and # of labels per cell should be equal')
                    end
                end
            else
                error('Unrecognized label input scheme')
                %error('# of labels: %d, not equal to the total # of columns: %d',length(in.labels),n_columns_total)
            end
%         else
%             error('Unsupported')
%             %I'm not sure this is correct if we are doing merge with multiple
%             %columns per cell entry
%             if length(in.labels) ~= length(x_data)
%                 error('Size of labels must equal the # of cells in the input')
%             end
        end
    end
    
    cur_data = x_data{1};
    
    if isempty(in.labels)
        cur_label = {};
    else
        cur_label = in.labels{1};
    end
    
    %recursive call ...
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
            %?? Is this handled by default?
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

% function h__replicateLabels