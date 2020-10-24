classdef subplotter < sl.obj.display_class
    %
    %   Class:
    %   sl.plot.subplotter
    %
    %   TODO: Add usage documentation below
    %
    %   Examples
    %   --------
    %
    %   *** createExampleGrid ***
    %   n_rows = 1;
    %   n_cols = 2;
    %   sp = sl.plot.subplotter.createExampleGrid(n_rows,n_cols);
    %
    %   *** subplot ***
    %   sp = sl.plot.subplotter(2,2);
    %   sp.subplot(1,1);
    %   plot(1:10,1:10)
    %   title('1,1');
    %   sp.subplot(1,2);
    %   plot(11:20,11:20)
    %   title('1,2');
    %   sp.subplot(2,1);
    %   plot(101:110,101:110)
    %   title('2,1');
    %   sp.subplot(2,2);
    %   plot(111:120,111:120)
    %   title('2,2');
    %
    %
        
    properties
        h_fig
        dims
        handles %cell array of Axes objects - some may be empty ...
        %
        %
        %
        
        last_index = 0
        %This can be used to omit specification of the axes
        %when calling the axes() method
        
        row_first_indexing %logical (default true)
        %
        %   true
        %   1 4
        %   2 5
        %   3 6
        %
        %   false
        %   1 2
        %   3 4
        %   5 6
        %
        %   NOT YET IMPLEMENTED
        %
        %   This would require something like sp.next() to be implemented.
        %
        %
    end
    properties (Dependent)
        n_rows
        n_columns
        y_extents
        x_extents
        y_gaps
        x_gaps
        widths
        heights
    end
    
    methods
        function value = get.n_rows(obj)
            value = obj.dims(1);
        end
        function value = get.n_columns(obj)
            value = obj.dims(2);
        end
        function value = get.y_extents(obj)
            y1 = obj.handles{end,1}.Position(2);
            y2 = obj.handles{1,1}.Position(2) + obj.handles{1,1}.Position(4);
            value = [y1 y2];
        end
        function value = get.x_extents(obj)
            %
            %   x_extents of all axes, i.e. the left border of column 1 
            %   and the right border of the right-most column
            %
            
            x1 = obj.handles{1,1}.Position(1);
            x2 = obj.handles{1,end}.Position(1) + obj.handles{1,end}.Position(3);
            value = [x1 x2];
        end
        function value = get.y_gaps(obj)
            if obj.n_rows == 1
                value = [];
            else
                all_positions = get([obj.handles{:,1}],'position');
                if ~iscell(all_positions)
                    all_positions = {all_positions};
                end
                all_bottoms = cellfun(@(x) x(2),all_positions);
                all_tops = cellfun(@(x) x(2)+x(4),all_positions);
                value = all_bottoms(1:end-1)-all_tops(2:end);
            end
        end
        function value = get.x_gaps(obj)
            if obj.n_columns == 1
                value = [];
            else
                all_positions = get([obj.handles{1,:}],'position');
                if ~iscell(all_positions)
                    all_positions = {all_positions};
                end
                all_lefts = cellfun(@(x) x(1),all_positions);
                all_rights = cellfun(@(x) x(1)+x(3),all_positions);
                value = all_lefts(2:end)-all_rights(1:end-1);
            end
        end
        function value = get.heights(obj)
            %
            %   Shape????
            
            all_positions = get([obj.handles{:,1}],'position');
            if ~iscell(all_positions)
                all_positions = {all_positions};
            end
            all_bottoms = cellfun(@(x) x(2),all_positions);
            all_tops = cellfun(@(x) x(2)+x(4),all_positions);
            value = all_tops - all_bottoms;
        end
        function value = get.widths(obj)
            %
            %   Shape????
            
            all_positions = get([obj.handles{1,:}],'position');
            if ~iscell(all_positions)
                all_positions = {all_positions};
            end
            all_lefts = cellfun(@(x) x(1),all_positions);
            all_rights = cellfun(@(x) x(1)+x(3),all_positions);
            value = all_rights-all_lefts;
        end
    end
    
    %Static Methods
    %-----------------------------------------------
    methods (Static)
        function obj = createExampleGrid(n_rows,n_cols)
            %
            %   sp = sl.plot.subplotter.createExampleGrid(n_rows,n_cols)
            %
            %   Example
            %   -------
            %   sp = sl.plot.subplotter.createExampleGrid(2,4);
            
            k = 0;
            for i = 1:n_rows
                for j = 1:n_cols
                    k = k + 1;
                    subplot(n_rows,n_cols,k);
                    plot([0 1],[k k])
                    set(gca,'ylim',[0 n_rows*n_cols + 1])
                end
            end
            obj = sl.plot.subplotter.fromFigure(gcf);
            
        end
        function [row,col] = linearToRowCol(id,n_rows_or_obj)
            %
            %   [row,col] = linearToRowCol(id,n_rows)
            %
            %   [row,col] = linearToRowCol(id,obj)
            
            if isobject(n_rows_or_obj)
                n_rows = n_rows_or_obj.n_rows;
            else
                n_rows = n_rows_or_obj;
            end
            col = floor((id-1)./n_rows) + 1;
            row = id - n_rows.*(col-1);
        end
        function subplot_index = linearToSubplotIndex(id,n_rows,n_cols)
            %
            %    TODO: Document the point of the function ...
            %
            %    subplot_index = sl.plot.subplotter.linearToSubplotIndex(id,n_rows,n_cols)
            %
            %    Also works for a vector ...
            
            
            %    TODO: We might want to shadow this in a sl.hg.subplot class
            
            %    1  4     =>    1  2
            %    2  5           3  4
            %    3  6           5  6
            
            col = floor((id-1)./n_rows) + 1;
            row = id - n_rows.*(col-1);
            
            subplot_index = (row - 1).*n_cols + col;
        end
    end
    
    %Constructors
    %-----------------------------------------------
    methods (Static)
        function obj = fromFigure(fig_handle,varargin)
            %x Construct object from figure handle
            %
            %   sp = sl.plot.subplotter.fromFigure(fig_handle,varargin)
            %
            %   Attempts to create object from figure handle. Requires
            %   trying to get subplot shape (unless shape is specified)
            %
            %   Optional Inputs
            %   ---------------
            %   shape : 2 element vector [n_rows, n_columns]
            %   may_be_single : default false
            %       If true, we may only have a single plot and not
            %       really a subplot ...
            %           Apparently this may not be needed ....
            
            %Changed the calling form from:
            %1) fig_handle, *shape
            %to 
            %2) fig_handle, varargin
            if nargin == 2
                add_shape = true;
                temp_shape = varargin{1};
                varargin(1) = [];
            else
                add_shape = false;
            end
            
            in.shape = [];
            in.may_be_single = false;
            in = sl.in.processVarargin(in,varargin);
            
            if add_shape
               in.shape = temp_shape; 
            end
            
            if ~isvalid(fig_handle)
                error('Invalid figure handle, figure likely closed')
            end
            
            try
                %Push this to getSubplotAxesHandles??
                if ~isempty(in.shape)
                    handles = findobj(gcf,'Type','axes');
                    grid_handles = reshape(flip(handles),shape(1),shape(2));
                else
                    temp = sl.hg.figure.getSubplotAxesHandles(fig_handle);
                    grid_handles = temp.grid_handles;
                end
                sz = size(grid_handles);
            catch ME
                %I saw this for a figure that was empty ...
                if in.may_be_single
                    error('Case not yet handled')
                   keyboard 
                else
                   rethrow(ME) 
                end
            end
            
            obj = sl.plot.subplotter(sz(1),sz(2),'clf',false);
            obj.handles = num2cell(grid_handles);
            obj.h_fig = fig_handle;
        end
    end
    
    methods
        function obj = subplotter(n_rows,n_columns,varargin)
            %
            %   obj = sl.plot.subplotter(n_rows,n_columns)
            %
            %   Optional Inputs
            %   ---------------
            %   clf : default true
            %       Whether to clear the figure or not.
            %   row_first_indexing : logical (default true)
            %       NOT YET IMPLEMENTED
            %
            
            in.h_fig = [];
            in.clf = true;
            in.row_first_indexing = true;
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(n_rows)
                obj.dims = n_columns;
            else
                obj.dims = [n_rows,n_columns];
            end
            
            obj.row_first_indexing = in.row_first_indexing;
            obj.handles = cell(n_rows,n_columns);
            obj.h_fig = in.h_fig;
            
            if in.clf
                if ~isempty(in.h_fig)
                    clf(in.h_fig);
                else
                    clf;
                end
            end
        end
    end
    
    %Methods
    %----------------------------------------------------------------------
    
    %----------    Layout manipulation    %----------------------
    methods
        function setHeightByPct(obj,pct)
            %TODO: Only called in dba plotters
            %remove those calls then remove this ...
            setRowHeightsByPct(obj,pct)
        end
        function setRowHeightsByPct(obj,pct)
            %X Scale all subplot heights by specified pct
            %
            %   setHeightByPct(obj,pct)
            %
            %   Inputs
            %   ------
            %   pct : array
            %       Same # of elements as rows, scales each row by
            %       specified percentage. Note the final heights are
            %       normalized to 1
            %
            %   Example
            %   -------
            %   sp = sl.plot.subplotter(3,1);
            %   for i = 1:3
            %       sp.subplot(i,1);
            %       plot(1:1000)
            %   end
            %   sp.setHeightByPct([0.1 0.2 0.3])
            
            n_columns_l = obj.dims(2); %l => local
            n_rows_l = obj.dims(1);
            
            %Normalize
            pct = pct./sum(pct);
            
            if length(pct) ~= n_rows_l
                error('PCT input must have same length as # of rows')
            elseif n_rows_l == 1
                error('Function not defined for a single row')
            end
            
            all_positions = get([obj.handles{:,1}],'position');
            
            all_bottoms = cellfun(@(x) x(2),all_positions);
            all_tops = cellfun(@(x) x(2)+x(4),all_positions);
            
            top_extent = all_tops(1);
            
            all_heights = all_tops - all_bottoms;
            total_height = sum(all_heights);
            
            new_heights = pct.*total_height;
            
            gap_heights = all_bottoms(1:end-1) - all_tops(2:end);
            
            next_top = top_extent;
            
            for iRow = 1:n_rows_l
                cur_height = new_heights(iRow);
                for iColumn = 1:n_columns_l
                    
                    cur_axes = obj.handles{iRow,iColumn};
                    cur_axes.Position(2) = next_top - cur_height;
                    cur_axes.Position(4) = cur_height;
                    %
                    % % % %                     cur_position = get(cur_axes,'position');
                    % % % %                     cur_position(2) = next_top - cur_height;
                    % % % %                     cur_position(4) = cur_height;
                    % % % %                     %???? Why is this not redrawing ...
                    % % % %                     cur_axes.Position = cur_position;
                    % % % % %                     set(cur_axes,'position',cur_position)
                    
                    %axis(cur_axes,in.axis)
                end
                if iRow ~= n_rows_l
                    next_top = next_top - cur_height - gap_heights(iRow);
                end
            end
        end
        function setWidthByPct(obj,pct)
            %Again, remove all calls
            setColumnWidthsByPct(obj,pct)
        end
        function setColumnWidthsByPct(obj,pct)
            %
            %   Example
            %   -------
            %   sp = sl.plot.subplotter(1,3);
            %   for i = 1:3
            %       sp.subplot(i);
            %       plot(1:1000)
            %   end
            %   sp.setColumnWidthsByPct([0.1 0.2 0.3])
            
            n_columns_l = obj.dims(2); %l => local
            n_rows_l = obj.dims(1);
            
            %Normalize
            pct = pct./sum(pct);
            
            if length(pct) ~= n_columns_l
                error('PCT input must have same length as # of rows')
            elseif n_columns_l == 1
                error('Function not defined for a single column')
            end
            
            all_positions = get([obj.handles{1,:}],'position');
            
            all_lefts = cellfun(@(x) x(1),all_positions);
            all_rights = cellfun(@(x) x(1)+x(3),all_positions);
            
            left_extent = all_lefts(1);
            
            all_widths = all_rights - all_lefts;
            total_width = sum(all_widths);
            
            new_widths = pct.*total_width;
            
            gap_widths = all_lefts(2:end) - all_rights(1:end-1);
            
            next_left = left_extent;
            
            for iCol = 1:n_columns_l
                cur_width = new_widths(iCol);
                for iRow = 1:n_rows_l
                    
                    cur_axes = obj.handles{iRow,iCol};
                    cur_position = get(cur_axes,'position');
                    cur_position(1) = next_left;
                    cur_position(3) = cur_width;
                    set(cur_axes,'position',cur_position)
                    
                    %axis(cur_axes,in.axis)
                end
                if iCol ~= n_columns_l
                    next_left = next_left + cur_width + gap_widths(iCol);
                end
            end
        end
    	function setYExtents(obj,y_min,y_max)
            %x Set y-extents (min and max) of plots
            %
            %   setYExtents(obj,y_min,y_max)
            %
            %   setYExtents(obj,[y_min,y_max])
            %
            %   setYExtents(obj,y_pad)
            %
            %   Approach
            %   --------
            %   All axes and gaps are scaled by the change in scale that is
            %   needed to accomodate the change from the old y-extents to
            %   the new ones.
            %
            %   Inputs
            %   ------------------------
            %   y_min :
            %       Range is from 0 to 1 where 0 corrsponds to the
            %       bottom-most border of the figure and 1 to the top-most
            %       border.
            %   y_max : 
            %   y_pad :
            %       In this format y_min == y_pad and y_max = 1-y_pad
            %
            %   Examples
            %   ---------
            %   sp = sl.plot.subplotter.createExampleGrid(2,4);
            %   sp.setYExtents(0.04,0.96)
            %   sp.setYExtents([0.04,0.96])
            %   sp.setYExtents(0.04)
            %
            %   See Also
            %   --------
            %   setXExtents
            
            if nargin == 2
                if length(y_min) == 1
                    y_max = 1 - y_min;
                elseif length(y_min) == 2
                    y_max = y_min(2);
                    y_min(2) = [];
                else
                    error('Unpected input')
                end
            end
            
            y1 = obj.y_extents;
            old_range = y1(2)-y1(1);
            new_range = y_max - y_min;
            scale = new_range/old_range;
            
            cur_top = y_max;
            
            all_heights = obj.heights;
            all_gaps = obj.y_gaps;
            
            new_heights = all_heights*scale;
            new_gaps = all_gaps*scale;
            
            for r = 1:obj.n_rows
                cur_bottom = cur_top - new_heights(r);
                for c = 1:obj.n_columns
                    cur_axes = obj.handles{r,c};
                    cur_axes.Position(4) = new_heights(r);
                    cur_axes.Position(2) = cur_bottom;
                end
                if r ~= obj.n_rows
                    cur_top = cur_bottom - new_gaps(r);
                end
            end
        end
        function setXExtents(obj,x_min,x_max)
            %x Set x-extents (min and max) of all plots
            %
            %   setXExtents(obj,x_min,x_max)
            %
            %   setXExtents(obj,[x_min,x_max])
            %
            %   setXExtents(obj,x_pad)
            %
            %   Approach
            %   --------
            %   All axes and gaps are scaled by the change in scale that is
            %   needed to accomodate the change from the old x-extents to
            %   the new ones.
            %
            %   Inputs
            %   ------------------------
            %   x_min :
            %       Range is from 0 to 1 where 0 corrsponds to the
            %       left-most border of the figure and 1 to the right-most
            %       border.
            %   x_max : 
            %   x_pad :
            %       In this format x_min == x_pad and x_max = 1-x_pad
            %
            %   Examples
            %   ---------
            %   %These are all equivalent calling formats:
            %   sp = sl.plot.subplotter.createExampleGrid(2,4);
            %   sp.setXExtents(0.05,0.95)
            %   sp.setXExtents([0.05,0.95])
            %   sp.setXExtents(0.05)
            %
            %   See Also
            %   --------
            %   setYExtents
            
            if nargin == 2
                if length(x_min) == 1
                    x_max = 1 - x_min;
                elseif length(x_min) == 2
                    x_max = x_min(2);
                    x_min(2) = [];
                else
                    error('Unpected input')
                end
            end
            
            x1 = obj.x_extents;
            old_range = x1(2)-x1(1);
            new_range = x_max - x_min;
            scale = new_range/old_range;
            
            cur_left = x_min;
            
            all_widths = obj.widths;
            all_gaps = obj.x_gaps;
            
            new_widths = all_widths*scale;
            new_gaps = all_gaps*scale;
            
            for c = 1:obj.n_columns
                cur_right = cur_left + new_widths(c);
                for r = 1:obj.n_rows
                    cur_axes = obj.handles{r,c};
                    cur_axes.Position(3) = new_widths(c);
                    cur_axes.Position(1) = cur_left;
                end
                if c ~= obj.n_columns
                    cur_left = cur_right + new_gaps(c);
                end
            end
        end
     	function removeVerticalGap(obj,rows,columns,varargin)
            %x Removes vertical gaps from subplots
            %
            %    removeVerticalGap(obj,rows,columns,varargin)
            %
            %    Inputs:
            %    -------
            %    rows : array
            %        Must be more than 1, should be continuous, starts at
            %        the top.
            %        The value -1 indicates that all rows should be
            %        compressed.
            %    columns :
            %        Which columns are affected
            %
            %    Optional Inputs:
            %    ----------------
            %    gap_size: default 0.02
            %        The normalized figure space that should be placed
            %        between figures.
            %    remove_x_labels : logical (default true)
            %
            %   Examples
            %   --------
            %   %TODO: Work in progress ...
            %   sp = sl.plot.subplotter.createExampleGrid
            
            h__matlabBugFixes(obj)
            
            if nargin == 1
                rows = 1:obj.n_rows;
                columns = 1:obj.n_columns;
            end
            
            %{
           subplot(2,1,1)
           plot(1:10)
           xlabel('testing')
           subplot(2,1,2)
           plot(2:20)
           xlabel('testing')
           sp = sl.plot.subplotter.fromFigure(gcf)
           sp.removeVerticalGap(1:2,1)
            %}
            
            in.gap_size = 0.02;
            in.keep_relative_size = true;
            in.remove_x_labels = true;
            in.remove_x_ticks = true;
            in = sl.in.processVarargin(in,varargin);
            
            %What's our expansion algorithm??????
            %Outer Position
            
            if rows == -1
                rows = 1:obj.n_rows;
            end
            
            %sl.
            
            
            all_axes = cellfun(@(x) sl.hg.axes(x),obj.handles(rows(1:end),columns(1)),'un',0);
            all_axes = [all_axes{:}];
            
            all_heights = [all_axes.height];
            pct_all_heights = all_heights./sum(all_heights);
            
            for iRow = 1:length(rows)-1
                cur_row_I = rows(iRow);
                for iCol = 1:length(columns)
                    cur_col_I = columns(iCol);
                    cur_ax = obj.handles{cur_row_I,cur_col_I};
                    a = sl.hg.axes(cur_ax);
                    a.clearLabel('x');
                    a.clearTicks('x');
                end
            end
            
            %Assuming all columns are the same ...
            top_axes    = all_axes(1);
            bottom_axes = all_axes(end);
            
            top_position = top_axes.position.top;
            bottom_position = bottom_axes.position.bottom;
            
            %TODO: This algorithm makes everything the same size. We need
            %to divy up based on the height
            
            if in.keep_relative_size
                total_height = top_position - bottom_position;
                gap_height   = (length(rows)-1)*in.gap_size;
                available_height = total_height - gap_height;
                new_heights = available_height*pct_all_heights;
                
                temp_start_heights = [0 cumsum(new_heights(1:end-1)+in.gap_size)];
                new_tops = top_position - temp_start_heights;
                new_bottoms = new_tops - new_heights;
            else
                %Add 1 due to edges
                %
                %        top     row 1   TOP OF TOP AXES
                %
                %        bottom  row 1  & top row 2
                %
                %        bottom  row 2  & top row 3
                %
                %        bottom  row 3   BOTTOM OF BOTTOM AXES
                %
                %    fill in so that each axes has the same height and so that
                %    all axes span from the top of the top axes to the bottom of
                %    the bottom axes
                temp = linspace(bottom_position,top_position,length(rows)+1);
                new_bottoms = temp(end-1:-1:1);
                new_tops = temp(end:-1:2);
            end
            
            for iRow = 1:length(rows)
                cur_row_I = rows(iRow);
                cur_new_top = new_tops(iRow);
                cur_new_bottom = new_bottoms(iRow);
                for iCol = 1:length(columns)
                    cur_col_I = columns(iCol);
                    cur_ax = obj.handles{cur_row_I,cur_col_I};
                    a = sl.hg.axes(cur_ax);
                    
                    %We can run into problems if we get a negative
                    %height between these two calls, so we need one that
                    %sets these at the same time
                    a.position.setTopAndBottom(cur_new_top,cur_new_bottom);
                    %                     a.position.top = cur_new_top;
                    %                     a.position.bottom = cur_new_bottom;
                end
            end
            %TODO: Verify continuity of rows
            %TODO: Verify same axes if removing x labels ...
        end
        function removeHorizontalGap(obj,varargin)
            %X removes horizontal gap
            %
            %   Optional Inputs
            %   ---------------
            %   remove_ticks : default false
            %       If true the y-ticks are removed, otherwise
            %       just the numbers are removed (if we remove the labels)
            %   no_gap_width : default 0.005
            %       This assumes normalized units. To make things look
            %       better we keep a very small gap between figures ...
            %   gap_width : default 0.02
            %       Gap to use when keeping labels
            %   remove_labels : default []
            %       - [] , remove labels if all the same
            %       - true, forces removal but errors on different
            %         y-labels
            %       - false, don't remove labels
            %
            %   Usage Notes
            %   -----------
            %   1) This appears to be sensitive to the zoom level so it is
            %   best run when the zoom is at its final level.
            %
            %
            %   Improvements
            %   ------------
            %   1) Allow optionally y-syncing first
            %   2) check y-lim - optional throw error if different
            
            %{
            clf
            sp = sl.plot.subplotter(1,4);
            for i = 1:3
            sp.subplot(i);
            plot(1:10)
            colorbar
            end
            sp.subplot(4)
            plot(1:10)

            sp.deleteColorBars('indices',1:2)
            sp.setAxesProps('ml_indices',2:3,'YTick',[])
            xlim = sp.handles{1}.XLim;
            sp.setAxesProps('ml_indices',1:3,'XLim',xlim)
            sp.setColWidthByTime('columns',1:3)
            sp.removeHorizontalGap('remove_labels',false);
            
            
            %}
            
            
            h__matlabBugFixes(obj)
            
            in.remove_ticks = false;
            
            %TODO: This naming is not great. Currently this code is broken
            %I think the distinction is not as important since I'm using
            %tight and not 'Position'
            in.no_gap_width = 0.01;
            in.gap_width = 0.01;
            
            in.remove_labels = []; %empty means do it if you can
            in = sl.in.processVarargin(in,varargin);
            
            n_columns_l = obj.n_columns;
            
            if n_columns_l == 1
                return
            end
            
            n_rows_l = obj.n_rows;
            
            remove_y_labels = true;
            if isempty(in.remove_labels) || in.remove_labels
                y_labels = cellfun(@(x) x.YLabel.String,obj.handles,'un',0);
                for i = 1:n_rows_l
                    if ~all(strcmp(y_labels(i,:),y_labels{i,1}))
                        if isempty(in.remove_labels)
                            remove_y_labels = false;
                            break
                        else
                            error('Currently can''t remove ylabels when not the same')
                            %Requested
                        end
                    end
                end
            else
                remove_y_labels = false;
            end
            
            if remove_y_labels
                for r = 1:n_rows_l
                    for c = 2:n_columns_l
                        cur_axis = obj.handles{r,c};
                        if in.remove_ticks
                            cur_axis.YTick = [];
                        else
                            cur_axis.YTickLabel = [];
                        end
                        %TODO: Have option to keep ticks but to remove #s
                        cur_axis.YLabel = [];
                    end
                end
            end
            
            %--------------------------------------------------------------
            %Gaps: lefts - rights
            %Resize: based on total size of the graphs without the 
            
            row_1_handles = [obj.handles{1,:}];
            
            full_positions = sl.hg.axes.getPosition(...
                row_1_handles,'add_colorbar',true,'as_struct',true,...
                'flatten_struct',true,'type','tight');
            graph_positions = sl.hg.axes.getPosition(...
                row_1_handles,'as_struct',true,'flatten_struct',true,...
                'type','p');
            
            total_width = full_positions.right(end) - full_positions.left(1);
            total_full_widths = sum(full_positions.width);
            all_graphs_width = sum(graph_positions.width);
            
            n_gaps = length(row_1_handles)-1;
            gap_widths = in.gap_width*ones(1,n_gaps);
            total_gap_widths = sum(gap_widths);
            
            extra_size = total_width - total_full_widths - total_gap_widths;
            
            %How much do we grow - allocate based on graph size, not total
            %size
            graph_pct_size = graph_positions.width./all_graphs_width;
            extra_graph_widths = extra_size.*graph_pct_size;
            
            new_full_widths = full_positions.width + extra_graph_widths;
            new_graph_widths = graph_positions.width + extra_graph_widths;
            
            cur_full_lefts = full_positions.left;
            
            %Now the tricky part, we want to move the figures
            %but we can only specify position or outer-position 
            %when what we really want to control is the tight
            %position of the group ...
            %
            %
            %   In other words, consider:
            %   graph & color left is 0.2
            %   but we need it to be at 0.15
            %
            %   but the axes is currently at 0.25
            %   so we need to move position from 0.25 to 0.2
            %
            %   want
            
            left_extent  = full_positions.left(1);

            %DEBUGGING
            %------------------------------------
%             log_p = cell(1,obj.n_columns);
%             log_t = cell(1,obj.n_columns);
%             target_lefts = zeros(1,obj.n_columns);
%             all_next_lefts = zeros(1,obj.n_columns);
            
            next_left = left_extent;
            for iColumn = 1:obj.n_columns
                
                %DEBUGGING
%                 all_next_lefts(iColumn) = next_left;
                
                
                new_full_width = new_full_widths(iColumn);
                new_graph_width = new_graph_widths(iColumn);
                cur_left = cur_full_lefts(iColumn);
                delta_left = next_left - cur_left;
                for iRow = 1:obj.n_rows
                    cur_axes = obj.handles{iRow,iColumn};

                    cur_position = get(cur_axes,'position');
                    cur_left_for_below = cur_position(1);
                    cur_position(3) = new_graph_width;
                    set(cur_axes,'position',cur_position)
                    drawnow()
                    
                    %Note, not sure how changing width redraws
                    %left and right so change width then move
                  	cur_position = get(cur_axes,'position');
                    cur_position(1) = cur_left_for_below + delta_left;
                    
                    set(cur_axes,'position',cur_position)               
                    drawnow()
                    
                    %DEBUGGING
%                     target_lefts(iColumn) = cur_left_for_below + delta_left; 
                    
                end
                
                %DEBUGGING
%                 log_p{iColumn} = sl.hg.axes.getPosition(...
%                     row_1_handles,'add_colorbar',false,'as_struct',true,...
%                     'flatten_struct',true,'type','p');
%             
%                 log_t{iColumn} = sl.hg.axes.getPosition(...
%                     row_1_handles,'add_colorbar',true,'as_struct',true,...
%                     'flatten_struct',true,'type','t');
            
                if iColumn ~= obj.n_columns
                    next_left = next_left + new_full_width + gap_widths(iColumn);
                end
            end   
            
        end
    end
    
    %----   Axes manipulation   %------------------------------------
    methods
        function setRowYLim(obj,row_I,ylim)
            %X Set ylim of all axes in a row
            %
            %   setRowYLim(obj,row_I,ylim)
            %
            %   Examples
            %   --------
            %   sp.setRowYLim(3,[-0.2 0.2])
            
            ax = [obj.handles{row_I,:}];
            set(ax,'ylim',ylim);
        end
        function setColWidthByTime(obj,varargin)
            %x Adjust column widths so that they are proportional to time
            %
            %   setColWidthByTime(obj)
            %
            %   This function adjusts column widths so that column
            %   widths are proportional to their time. In other words
            %   if one column spans 1 second and another 2 seconds, the
            %   latter column would be made to take up 2/3 of the available
            %   width.
            %
            %   This can change the xlim, so the xlim neeeds to be manual
            %   before this ...
            %
            %   Yikes, I wonder if this is going to change my xlim
            %   which would make this circular ...
            %   - it does, so the xlim needs to be manual before this ...
            %
            %   TODO: Units need to be normalized ...
            %
            %   Optional Inputs
            %   ---------------
            %   axis : default 'normal'
            %       'auto'
            %       'normal'
            %       'tight'
            %       'fill'
            %       etc => see help(axis)
            %
            %   Usage Notes
            %   -----------
            %   1) If the x-limits change as a result of the resize this
            %   will fail. Consider setting the limits before running. For
            %   example in my use case I had this:
            %
            %   xlim = sp.handles{1}.XLim;
            %   sp.setAxesProps('ml_indices',1:3,'XLim',xlim)
            %   sp.setColWidthByTime('columns',1:3)
            
            in.columns = [];
            in.axis = '';
            in = sl.in.processVarargin(in,varargin);
           
            if ~isempty(in.axis)
                error('axis changing not yet implemented')
            end
            
            if obj.n_columns == 1
                return
            end
            
            %This seems to be needed in case we haven't updated positions
            %from prior actions ...
            drawnow()
            
            row_1_handles = [obj.handles{1,:}];
            if isempty(in.columns)
                in.columns = 1:obj.n_columns;
            else
                if any(diff(in.columns) ~= 1)
                    error('Currently only support neighboring columns')
                end
                row_1_handles = row_1_handles(in.columns);
            end
            
            
            ps = sl.hg.axes.getPosition(row_1_handles,...
                'type','position','as_struct',true,'add_colorbar',true,...
                'flatten_struct',true);
            
            %TODO: Rearranging needs to take into account
            %the text
%             ps_full = sl.hg.axes.getPosition(row_1_handles,...
%                 'type','outer','as_struct',true,'flatten_struct',true,...
%                 'add_colorbar',true);
            
            all_xlims = get(row_1_handles,'xlim');
            
            all_widths = ps.width;
            total_width = sum(all_widths);
            all_time_durations = cellfun(@(x) x(2)-x(1),all_xlims);
            
            all_lefts = ps.left;
            all_rights = ps.right;
            
            left_extent  = all_lefts(1);

            pct_durations = all_time_durations/sum(all_time_durations);
            new_widths = pct_durations*total_width;
            
            gap_widths = all_lefts(2:end) - all_rights(1:end-1);
            
            %This seems to require a 2 step process (not sure why)
            %--------------------------------------------------------------
            %1) Adjust left
            next_left = left_extent;
            n_columns_l = length(in.columns);
            n_rows_l = obj.n_rows;
            for iColumn = 1:n_columns_l
                cur_column = in.columns(iColumn);
                cur_width = new_widths(iColumn);
                for iRow = 1:n_rows_l
                    cur_axes = obj.handles{iRow,cur_column};
                    cur_position = get(cur_axes,'position');
                    cur_position(3) = cur_width;
                    set(cur_axes,'position',cur_position)
                    drawnow()
                    
                    cur_position = get(cur_axes,'position');
                    cur_position(1) = next_left;
                    set(cur_axes,'position',cur_position)
                    drawnow()
                    
                    %Not sure how to handle this because we really only
                    %want the y lim to change because we've just put in a
                    %bunch of effort to scale graphs based on x ...
                    %axis(cur_axes,in.axis)
                    %
                    % i.e. we don't want the xlim values to change after 
                    % we've gone ahead and adjusted widths based on the old
                    % xlims ...
                end
                if iColumn ~= n_columns_l
                    next_left = next_left + cur_width + gap_widths(iColumn);
                end
            end
            
        end
    end
    
    
    methods
        function varargout = subplot(obj,row_or_index,column)
            %x Create the actual subplot axis
            %
            %   ax = subplot(obj,row,column)
            %
            %   ax = subplot(obj,index)
            %
            %   %Plots in the next location
            %   %TODO: Support subplot or matlab next indexing
            %   ax = subplot(obj)
            %
            %   Example
            %   -------
            %   Plot to the 2nd row, 3rd column
            %   ax = sp.subplot(2,3);
            
            if nargin == 1
                %TODO: Support row_first_indexing
                %This was originally addded to support a row vector
                %so it didn't matter ...
                row_or_index = obj.last_index + 1;
                [row,column] = ind2sub([obj.n_rows,obj.n_columns],row_or_index);
                obj.last_index = row_or_index;
            elseif nargin == 2
                [row,column] = ind2sub([obj.n_rows,obj.n_columns],row_or_index);
            else
                row = row_or_index;
            end
            
            I = (row-1)*obj.n_columns + column;
            
            %I'm not aware of any way of forcing h_fig to subplot
            if ~isempty(obj.h_fig)
                figure(obj.h_fig)
            end
            
            ax = subplot(obj.n_rows,obj.n_columns,I);
            obj.handles{row,column} = ax;
            
            %If we don't have a figure on record, log it now ...
            if isempty(obj.h_fig)
                obj.h_fig = get(ax,'Parent');
            end
            
            if nargout
                varargout{1} = ax;
            end
        end
        function setLineProps(obj,varargin)
            %x Sets properties of all lines in the axes
            %
            %   setLineProps(obj,varargin)
            %
            %   Example
            %   -------
            %   sp.setLineProps('LineWidth',3)
            %
            %   %Only apply to lines with 10 or more points
            %   sp.setLineProps(10,'LineWidth',3)
            %
            %   %Only apply to lines with 3 or fewer points
            %   sp.setLineProps(-3,'LineWidth',2,'Color','k')
            
            use_lt = false;
            if isnumeric(varargin{1})
               limit = varargin{1};
               varargin(1) = [];
               if limit < 0
                   limit = abs(limit);
                   use_lt = true;
               end
            else
                limit = 0;
            end
            
            if use_lt
                for i = 1:obj.n_rows
                    for j = 1:obj.n_columns
                        ax = obj.handles{i,j};
                        c = ax.Children;
                        for k = 1:length(c)
                            cur_c = c(k);
                            if strcmp(cur_c.Type,'line') && length(cur_c.XData) <= limit
                               set(cur_c,varargin{:}) 
                            end
                        end
                    end
                end
            else
                for i = 1:obj.n_rows
                    for j = 1:obj.n_columns
                        ax = obj.handles{i,j};
                        c = ax.Children;
                        for k = 1:length(c)
                            cur_c = c(k);
                            if strcmp(cur_c.Type,'line') && length(cur_c.XData) >= limit
                               set(cur_c,varargin{:}) 
                            end
                        end
                    end
                end   
            end
        end
        function output = getYRange(obj,varargin)
            in.type = 'by_row';
            %-all
            %
            in.rows = [];
            in.columns = [];
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(in.rows)
                in.rows = 1:obj.n_rows;
            end
            
            if isempty(in.columns)
                in.columns = 1:obj.n_columns;
            end
            
            y_min = zeros(1,length(in.rows));
            y_max = zeros(1,length(in.rows));
                        
            for i = 1:length(in.rows)
                cur_row = in.rows(i);
                y_temp = zeros(2,length(in.columns));
                for j = 1:length(in.columns)
                    cur_col = in.columns(j);
                    y_temp(:,j) = get(obj.handles{cur_row,cur_col},'YLim');
                end
                y_min(i) = min(y_temp(1,:));
                y_max(i) = max(y_temp(2,:));
            end
            
            output = [y_min(:) y_max(:)];
            
        end
        function setAxesProps(obj,varargin)
            %x Sets properties of all axes
            %
            %   setAxesProps(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   rows :
            %   columns :
            %   ml_indices : 
            %       Note, this can't be used with rows and columns. This
            %       uses MatLab indexing rather than subplot indexing.
            %       1 3
            %       2 4
            %
            %   Example
            %   -------
            %   sp.setAxesProps('FontSize',16,'FontName','Arial')
            %
            %   Improvements
            %   ------------
            %   Support sp_indices 1 2
            %                      3 4
            
            in.rows = [];
            in.columns = [];
            in.ml_indices = [];
            [in,new_v] = sl.in.processVararginWithRemainder(in,varargin);
            
            if ~isempty(in.ml_indices)
                for i = 1:length(in.ml_indices)
                    cur_I = in.ml_indices(i);
                    set(obj.handles{cur_I},new_v{:})
                end
            else      
                rows = in.rows;
                cols = in.columns;
                if isempty(rows)
                    rows = 1:obj.n_rows;
                end
                if isempty(cols)
                    cols = 1:obj.n_columns;
                end
                for i = 1:length(rows)
                    r = rows(i);
                    for j = 1:length(cols)
                        c = cols(j);
                        set(obj.handles{r,c},new_v{:})
                    end
                end
            end
        end
        function axes(obj,row,column)
            %x NYI - this is supposed to activate a particular axes
            %
            %    Calling Forms:
            %    --------------
            %    1) Specify the index to make active
            %    axes(obj,index)
            %
            %    2) Specify the location to make active by row & column
            %    axes(obj,row,column)
            %
            %    3) Make the next axes active (increment index by 1)
            %    axes(obj)
            %
            %    The goals is to have this be equivalent
            %    to calling subplot()
            %
            %    1) call subplot
            %
            %    Improvement:
            %    ------------
            %    1) Implement row_first_indexing
            %    2)
            %
            %    sp = sl.plot.subplotter
            
            error('Not yet implemented')
            
            %
            keyboard
            if nargin == 0
                %Use last index
            elseif nargin == 1
                sp_index = row;
            else
                %1 2
                %3 4
                %NOTE: This is currently for row_first_indexing = true
                sp_index = column + (row-1)*obj.dims(2);
            end
            obj.last_index = sp_index;
        end
        function stackColumns(obj)
            %NYI
            %
            %   Take all columns and plot as one row.
            keyboard
            
            %TODO: I need to finish implementing proper copy figure
        end
        function clearColumn(obj,column)
            %
            %   clearColumn(obj,column)
            %
            %   Inputs
            %   ------
            %   column : scalar
            %       Column ID
            %
            %   Example
            %   -------
            %   subplot(1,2,1)
            %   plot(1:10)
            %   subplot(1,2,2)
            %   plot(11:20)
            %   title('This will be deleted')
            %   pause(3)
            %   sp = sl.plot.subplotter.fromFigure(gcf);
            %   %Clear column 2
            %   sp.clearColumn(2)
            
            for i = 1:obj.n_rows
                cur_axes = obj.handles{i,column};
                delete(cur_axes)
            end
        end

        function linkXAxes(obj,varargin)
            %X Keep same x-limits for all axes
            %
            %   linkXAxes(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   by_column : default false
            %       - true, columns are linked
            %       - false, all axes are linked, even across columns
            %
            %
            %   Improvements
            %   ---------------
            %   https://undocumentedmatlab.com/blog/using-linkaxes-vs-linkprop
            %
            %   See Also
            %   --------
            %   linkaxes
            
            in.clear_previous_links = false; %NYI
            in.by_column = false;
            in = sl.in.processVarargin(in,varargin);
            
            h = obj.handles;
            if in.by_column
                for i = 1:obj.n_columns
                    column_h = [h{:,i}];
                    %syncLimits(column_h,'XLim');
                    %linkprop(column_h,'XLim');
                    linkaxes(column_h,'x');
                end
            else
                all_handles = [h{:}];
                %TODO: Warning: Excluding ColorBars, Legends and non-axes
                %Can we disable this ????
                %'MATLAB:linkaxes:RequireDataAxes'
                %
                %- gets thrown for deleted axes
                
                all_handles = all_handles(isvalid(all_handles));
                linkaxes(all_handles,'x');
                %syncLimits(all_handles,'XLim');
                %linkprop(ax,'XLim');
            end
        end
        function linkYAxes(obj,varargin)
            %X Keep same y-limits for all axes
            %
            %   linkYAxes(obj,varargin)
            %
            %   Currently I've only implemented linking each row
            %   independently, eventually we could link all rows ...
            %
            %   See Also
            %   --------
            %   linkaxes
            
            in.columns = [];
            in.clear_previous_links = false; %NYI
            in.by_row = true; %NYI
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(in.columns)
               in.columns = 1:obj.n_columns; 
            end
            
            for i = 1:obj.n_rows
                %TODO: Do we need to expand first
                %I think this sometimes shrinks rather than expanding :/
                ax = [obj.handles{i,in.columns}];
                linkaxes(ax,'y')
                %syncLimits(ax,'YLim');
                %linkprop(ax,'YLim');
            end
        end
        function h_axes = getAxesAtIndex(obj,index)
           [row,col] = obj.linearToRowCol(index,obj); 
           h_axes = obj.handles{row,col};
        end
        function ylabel_to_title(obj)
            %X Moves string from ylabel to title
            %
            %   ylabel_to_title(obj)
            
            h_local = obj.handles;
            for i = 1:obj.n_rows
                for j = 1:obj.n_columns
                    h_axes = h_local{i,j};
                    y_text = h_axes.YLabel.String;
                    title(h_axes,y_text);
                    h_axes.YLabel.String = '';
                end
            end
        end
        function deleteColorBars(obj,varargin)
            %X
            %
            %   deleteColorBars(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   row_indices :
            %       Which indices to target. Uses Matlab subplot
            %       indexing ...
            
            in.ml_indices = [];
            in.sp_indices = [];
            in = sl.in.processVarargin(in,varargin);
            
            ml_indices = h__resolveIndices(obj,in);
            
            for i = 1:length(ml_indices)
                h_axes = obj.handles{ml_indices(i)};
                %https://www.mathworks.com/matlabcentral/answers/358266-get-colorbar-handle-for-a-particular-image
                h_color = h_axes.Colorbar;
                if ~isempty(h_color)
                   delete(h_color) 
                end
            end
        end
    end
    
    
end

function ml_indices = h__resolveIndices(obj,in)
    %ml_indices
    %sp_indices
    
    if ~isempty(in.sp_indices)
        error('Not yet implemented')
    elseif ~isempty(in.ml_indices)
        ml_indices = in.ml_indices;
    else
        ml_indices = 1:obj.n_rows*obj.n_columns;
    end
end

function h__matlabBugFixes(obj)
    %:/ not sure where this came from ...
    for i = 1:obj.n_rows
        for j = 1:obj.n_columns
            ax = obj.handles{i,j};
        	if isappdata(ax, 'SubplotDeleteListenersManager')
                temp = getappdata(ax, 'SubplotDeleteListenersManager');
                try
                    delete(temp.SubplotDeleteListener);
                end
                rmappdata(ax, 'SubplotDeleteListenersManager');
            end
        end
    end
end

