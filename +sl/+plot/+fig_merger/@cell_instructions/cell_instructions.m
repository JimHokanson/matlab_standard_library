classdef cell_instructions < handle
    %
    %   Class:
    %   sl.plot.fig_merger.cell_instructions
    
    properties
        target_row
        target_col
        source_fig_id
        
        %Note, we'll wait until we get the figure to disambiguate 
        %id vs row,col (because we need to know # of rows to go from
        %id to row,col
        source_id
        source_row %these may or may not be defined ...
        source_col
    end
    
    methods
        function obj = cell_instructions(t_row,t_col,raw_string)
            %1,1 - fig 1, id 1
            %1,1,1 - fig 1, row 1, col 1
            %3, 2, 1 - fig 3, row 2, col 1
            
            obj.target_row = t_row;
            obj.target_col = t_col;
            if nargin == 2
                return
            end
            
            temp = regexp(raw_string,',','split');
            values = cellfun(@str2double,temp);
            
            if length(values) == 3
                obj.source_fig_id = values(1);
                obj.source_row = values(2);
                obj.source_col = values(3);
            elseif length(values) == 2
                obj.source_fig_id = values(1);
                obj.source_id = values(2);
            elseif length(values) == 1
                obj.source_fig_id = values(1);
                obj.source_id = 1;
            else
                error('Unexpected format for string: %s',raw_string)
            end
            
        end
    end
end

