classdef table < handle
    %
    %   Class:
    %   sl.ml.current_folder_viewer.table
    %
    %   The current folder appears to be composed of a toolbar and a table.
    %   This class wraps table methods.
    %
    %   See Also
    %   --------
    %   sl.ml.current_folder_viewer
    
    properties
        h
    end
    

    
    properties (Dependent)
        row_count %This changes when folders are expanded ...
    end
    
    methods
        function value = get.row_count(obj)
            value = obj.h.getRowCount();
        end
    end
    
    methods
        function obj = table(cfe_h)
            obj.h = cfe_h.getTable();
            
            %Methods
            %-------
            %1) get row by name?
            %2) get row by index
        end
        function row = getRowByIndex(obj,index)
            %
            %   Inputs
            %   ------
            %   index : 1 based
            %
            %   Outputs
            %   -------
            %   
            h2 = obj.h.getRowAt(index-1);
            if isempty(h2)
                row = [];
            else
                row = sl.ml.current_folder_viewer.table_row(h2,obj.h);
            end
        end
        function collapseAll(obj)
            obj.h.collapseAll();
        end
        function collapseFirstLevel(obj)
            obj.h.collapseFirstLevel;
        end
        function expandAll(obj)
            %This seems to be the same as expandFirstLevel ...
            obj.h.expandAll();
        end
        function expandFirstLevel(obj)
            obj.h.expandFirstLevel();
        end
        function launchFileSearcher(obj)
           obj.h.startFileSearch();
           %??? Can we get a handle to this ...
        end
        function expandRowByIndex(obj,index)
           obj.h.expandRow(index-1,true);
        end
        function collapseRowByIndex(obj,index)
           obj.h.expandRow(index-1,false); 
        end
    end
end

%c = t.getColumnCount