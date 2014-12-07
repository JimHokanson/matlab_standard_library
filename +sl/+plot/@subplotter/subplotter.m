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
    end
    
    methods
        function obj = subplotter(dims)
            %
            %   obj = sl.plot.subplotter(dims)
            %   
            obj.dims = dims; 
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
    
end

