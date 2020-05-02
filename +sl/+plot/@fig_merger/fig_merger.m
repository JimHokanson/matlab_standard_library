classdef fig_merger < handle
    %
    %   Class:
    %   sl.plot.fig_merger
    %
    %   The goal of this code is to merge axes from various figures into
    %   one figure where you specify which subplot you want each axes to
    %   end up in.
    
    properties
        h_fig
        h
        subplotter_result
    end
    
    methods
        function obj = fig_merger(data)
            %
            %   sl.plot.fig_merger(data)
            %
            %   %Launches GUI
            %   sl.plot.fig_merger 
            %
            %   Input data
            %   ------------------
            %   
            
            if ~isempty(data)
                instr = obj.instrFromCellstr(data);
                obj.move(instr);
            else
                obj.launchGUI();
            end
        end
        function move(obj,instr)
            %
            %   instr : [sl.plot.fig_merger.cell_instructions]
            
            
            fig_ids = unique([instr.source_fig_id]);
            
            n_figs = length(fig_ids);
            all_fig_sp = cell(1,n_figs);
            for i = 1:n_figs
                h_fig2 = figure(fig_ids(i));
                all_fig_sp{i} = sl.plot.subplotter.fromFigure(h_fig2);
            end
            
            n_target_rows = max([instr.target_row]);
            n_target_cols = max([instr.target_col]);
            
            h_target_fig = figure();
            sp = sl.plot.subplotter(n_target_rows,n_target_cols);
            obj.subplotter_result = sp;
            
            for i = 1:length(instr)
                
                cur_instructions = instr(i);
                
                source_fig_id = cur_instructions.source_fig_id;
                source_id = cur_instructions.source_id;
                
                sp_source = all_fig_sp{fig_ids == source_fig_id};
                
                if isempty(source_id)
                    source_row = cur_instructions.source_row;
                    source_col = cur_instructions.source_col;
                else
                    [source_row,source_col] = sp_source.linearToRowCol(source_id,sp_source);
                end
                
                source_axes = sp_source.handles{source_row,source_col};
                
                target_row = cur_instructions.target_row;
                target_col = cur_instructions.target_col;
                
                temp_axes = sp.subplot(target_row,target_col);
                p = temp_axes.Position;
                u = temp_axes.Units;
                delete(temp_axes)
                
                h_legend = findobj(figure(source_fig_id), 'Type', 'Legend');
                
                if ~isempty(h_legend)
                    %https://www.mathworks.com/matlabcentral/answers/277007-determine-axes-handle-to-which-a-legend-belongs
                    axes = [h_legend.Axes];
                    h_legend = h_legend(axes == source_axes);
                end

                
                %Object Copy of Axes with
% multiple coordinate systems
% is not supported.
%TODO: Support this ...
%https://www.mathworks.com/matlabcentral/answers/157055-how-to-workaround-the-plotyy-copyobj-error
                if ~isempty(h_legend)
                    %Needs to be moved together ...
                    h_temp = copyobj([h_legend source_axes],h_target_fig);
                    h_axes3 = h_temp(2);
                else
                    h_axes3 = copyobj(source_axes,h_target_fig);
                end
                drawnow()
                h_axes3.Units = u;
                h_axes3.Position = p;                
            end
            
            
            
        end
        function launchGUI(obj)
            BASE_PATH = sl.stack.getMyBasePath;
            fig_name = 'fig_merger.fig';
            gui_path = fullfile(BASE_PATH, fig_name);
            obj.h_fig = openfig(gui_path);
            obj.h = guihandles(obj.h_fig);
            
            obj.h.data.Data = cell(8,8);
            
            obj.h.merge.Callback = @(~,~)obj.processTable();
        end
        function instr = instrFromCellstr(obj,data)
            n_rows = size(data,1);
            n_cols = size(data,2);
            instr = cell(n_rows,n_cols);
            for i = 1:n_rows
                for j = 1:n_cols
                    instr{i,j} = sl.plot.fig_merger.cell_instructions(i,j,data{i,j});
                end
            end 
            instr = [instr{:}];
        end
        function processTable(obj)
            data = obj.h.data.Data;
            has_data = ~cellfun('isempty',data);
            %TODO: Have a better check here ...
            n_rows = find(has_data(:,1),1,'last');
            n_cols = find(has_data(1,:),1,'last');
            
            instr = obj.instrFromCellstr(data(1:n_rows,1:n_cols));
            
            obj.move(instr);
        end
    end
end

