classdef workspace_viewer
    %
    %   Class:
    %   sl.ml.workspace_viewer
    %
    %   http://undocumentedmatlab.com/blog/customizing-matlabs-workspace-table
    %   https://undocumentedmatlab.com/blog/customizing-workspace-context-menu
    %
    %   ******* This class is a work in progres.
    %
    %   See Also
    %   --------
    %   sl.cmd_window
    %   sl.ml.desktop
    
    properties
        h
        all_names
    end
    
    methods
        function obj = workspace_viewer()
            %
            %   obj = sl.ml.workspace_viewer
            ml_desktop = sl.ml.desktop.getInstance();
            ws_temp = ml_desktop.d.getClient('Workspace');
            obj.h = ws_temp.getComponent(0).getComponent(0).getComponent(0);
            
            n_columns = obj.h.getColumnCount();
            
            local_h = obj.h;
            %obj.h.getVariableNames(0)
            %getVariableDims  %e.g. '5x5' <= string
            %getVariableClasses
            %getVariableNames
            %getValueAt
            
            %Returns name of column
            %wtf5 = obj.h.getValueAt()
            %wtf5 = obj.h.getFieldCount %13
            %isFieldShowing
            %obj.h.getFieldName(index)
            
            n_rows = obj.h.getRowCount;
            local_all_names = cell(1,n_rows);
            t1 = tic;
            for iRow = 0:(n_rows-1)
                local_all_names{iRow+1} = char(local_h.getVariableNames(iRow));
            end
            obj.all_names = local_all_names;
            %obj.time_names = toc(t1);
        end
    end
    
end

