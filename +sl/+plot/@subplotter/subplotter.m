classdef subplotter < sl.obj.display_class
    %
    %   Class:
    %   sl.plot.subplotter
    
    %sp = sl.plot.subplot(3,2)
%sp.p(1,1)
%plot()
%sp.clean()
%sp.title
%sp.xlabel
%sp.ylabel
%... = sp.handles
%
%   Both of the below methods require
%   TODO: We could allow passing in columns with which to work
%   like only work with a given set of columns ...
%sp.setColWidthByTime
%sp.setColWidthByPct

    
    properties
        dims
        handles
        last_index = 0
        %This can be used to omit specification of the axes
        %when doing
        
        row_first_indexing
    end
    
    methods
        function obj = subplotter(n_rows,n_columns)
            %
            %   obj = sl.plot.subplotter(n_rows,n_columns)
            %
            %   Note, as much as I would like to be able to support
            %   
            %   Optional Inputs
            %   ---------------
            %   row_first_indexing : logical (default true)
            %       NOT YET IMPLEMENTED
            %       
            
            in.row_first_indexing = true;
            
            if isempty(n_rows)
                obj.dims = n_columns;
            else
                obj.dims = [n_rows,n_columns];
            end
            
            obj.row_first_indexing = in.row_first_indexing;
        end
        function axes(obj,row,column)
           %
           %    Calling Forms:
           %    --------------
           %    axes(obj,index)
           %
           %    axes(obj,row,column)
           %
           %    axes(obj)
           %    
           %    The goals is to have this be equivalent
           %    to calling subplot
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
        function setColWidthByTime(obj)
            %Yikes, I wonder if this is going to change my xlim
            %which would make this circular ...
            %
            %   TODO: Units need to be normalized ...

           all_positions = get(obj.handles(1,:),'position');
           all_xlims     = get(obj.handles(1,:),'xlim');

           all_lefts = cellfun(@(x) x(1),all_positions);
           all_rights = cellfun(@(x) x(1)+x(3),all_positions);
           
           left_extent = all_lefts(1);
           right_extent = all_rights(end);
           
           all_widths = all_rights - all_lefts;
           all_time_durations = cellfun(@(x) x(2)-x(1),all_xlims);
           
           total_width = sum(all_widths);
           
           pct_durations = all_time_durations/sum(all_time_durations);
           new_widths = pct_durations*total_width;
           
           gap_widths = all_lefts(2:end) - all_rights(1:end-1);
           
           next_left = left_extent;
           n_columns = obj.dims(2);
           n_rows = obj.dims(1);
           for iColumn = 1:n_columns
               cur_width = new_widths(iColumn);
               for iRow = 1:n_rows
                  cur_position = get(obj.handles(iRow,iColumn),'position');
                  cur_position(1) = next_left;
                  cur_position(3) = cur_width;
                  set(obj.handles(iRow,iColumn),'position',cur_position)
               end
               if iColumn ~= n_columns
                  next_left = next_left + cur_width + gap_widths(iColumn); 
               end
           end
        end
    end
    methods (Static)
        function obj = fromFigure(fig_handle)
            %
            %   sp = sl.plot.subplotter.fromFigure(fig_handle)
           temp = sl.figure.getSubplotAxesHandles(fig_handle);
           
           sz = size(temp.grid_handles);
           
           obj = sl.plot.subplotter(sz(1),sz(2));
           obj.handles = temp.grid_handles;
           
        end
    end
    
end

