classdef table_row_raw < handle
    %
    %   Class:
    %   sl.ml.current_folder_viewer.table_row_raw
    %
    %   Matlab Classes
    %   --------------
    %   com.jidesoft.grid.Row <= not seen in testing
    %   com.mathworks.widgets.grouptable.GroupingTableRow
    %
    %   **** This is meant to be a table row without any processing
    %   whereas the other class will have my tweaks built in ...
    %
    %   I want the table to be able to create either on demand
    %
    %
    %   See Also
    %   --------
    %   sl.ml.current_folder_viewer.table
    %
    %   Cell Access
    %   -----------
    %   getValueAt(#) - 0 based
    %   0 - javax.swing.ImageIcon@115f7313
    %   1 - string
    %   2 - 'com.mathworks.sourcecontrol.StringIcon'
    
    properties
        h
    end
    
    properties (Hidden)
        t
        item %class com.mathworks.matlab.api.explorer.FileSystemEntry
    end
    
    properties (Dependent)
        level
        is_expandable
        %This does not appear to be reliable. An empty folder is marked
        %as expandable ...
        %
        %If however we get an enumerator, then non-expandable will only
        %have itself (1 item)
        
        expanded
        %Setting this only appears to work at the top level. Otherwise it
        %is only respected when opening :/ WTF!!!!!!!
        %
        %This also appears to get stale if the user clicks on anything
        %after it is created ...
        
        all_n_children
        all_n_visible_children
        n_children
        %When not expanded, this appears to be 1 for folders ...
        
        n_visible_children
        n_visible_expandable
        
        %item info
        %-------------
        is_folder
        is_os_directory
        is_real
        is_zip_or_jar
        name
        size
        location %com.mathworks.matlab.api.explorer.FileLocation
    
        has_children
        has_visible_children
    end
    
    
    %{
getAllChildrenCount              
getAllVisibleChildrenCount                           
getChildrenCount                                         
getLoadedVerticalAttributeCount  
getLoadedVerticalAttributes                         
                                      
getPropertyChangeListeners       
getTreeTableModel                
getValueAt                                      
%}
    
    methods
        function value = get.all_n_visible_children(obj)
           value = obj.h.getAllVisibleChildrenCount;
        end
        function value = get.all_n_children(obj)
            value = obj.h.getAllChildrenCount;
        end
        function value = get.has_children(obj)
            value = obj.h.hasChildren;
        end
        function value = get.has_visible_children(obj)
           value = obj.h.hasVisibleChildren; 
        end
        function value = get.level(obj)
           value = double(obj.h.getLevel); 
        end
        function value = get.is_expandable(obj)
            %TODO: get enumerator and use that ...
            %
            %Does this depend on the Matlab version ...
            
            %In 2018b this is true for an empty folder
            
            value = obj.h.getChildrenCount ~= 0;
            
            %value = obj.h.isExpandable;
        end
        function value = get.expanded(obj)
            value = obj.h.isExpanded;
        end
        function set.expanded(obj,value)
            
            gtm = handle(obj.t.getNavigableModel());
            n_rows = gtm.RowCount;
            gtm.expandRow(obj.h,value);
            
            %This isn't ideal, we need some way of blocking
            %- basically this just waits for a bit, and if the # of rows
            %  is still changing, waits a bit more
            for i = 1:100
                pause(0.25)
                n2 = gtm.RowCount();
                if n2 == n_rows
                   break 
                end
                n_rows = n2;
            end
%               for i = 1:100
%                   pause(0.01)
%                   disp(gtm.isAdjusting)
%               end
%             obj.h.setExpanded(value);
%             pause(1)
        end
        function value = get.n_children(obj)
            value = double(obj.h.getChildrenCount);
        end
        function value = get.n_visible_children(obj)
            value = double(obj.h.getNumberOfVisibleChildren); 
        end
        function value = get.n_visible_expandable(obj)
            value = double(obj.h.getNumberOfVisibleExpandable);
        end
        function value = get.is_folder(obj)
            value = obj.item.isFolder;
        end
        function value = get.is_os_directory(obj)
            value = obj.item.isOSDirectory;
        end
        function value = get.is_real(obj)
            value = obj.item.isReal;
        end
        function value = get.is_zip_or_jar(obj)
            value = obj.item.isZipOrJar;
        end
        function value = get.name(obj)
            value = char(obj.item.getName);
        end
        function value = get.size(obj)
            value = obj.item.getSize;
        end
        function value = get.location(obj)
            %TODO: wrap this as an object
            value = obj.item.getLocation;
        end
    end
    
    methods
        function obj = table_row(h,t)
            obj.h = h;
            obj.t = t;
            obj.item = h.getItem();
        end
        function obj2 = getParent(obj)
            %
            %   Outputs
            %   -------
            %   obj2 : sl.ml.current_folder_viewer.table_row OR []
            %       Apparently if the parent is not visible, we don't
            %       get a valid handle. In this case the output is empty
            
            h2 = obj.h.getParent();
            if isempty(h2)
                obj2 = [];
            else
                obj2 = sl.ml.current_folder_viewer.table_row(h2,obj.t);
            end
        end
        function obj2 = getChildByIndex(obj,index)
            h2 = obj.h.getChildAt(index-1);
            if isempty(h2)
                obj2 = [];
            else
                obj2 = sl.ml.current_folder_viewer.table_row(h2,obj.t);
            end
        end
    end
end

%{
addChild                         
addChildren                      
addPropertyChangeListener        
breadthFirstEnumeration          
cellUpdated                      
depthFirstEnumeration            
equals                           
getAllChildrenCount              
getAllVisibleChildrenCount       
getCellClassAt                   
getChildAt                       
getChildIndex                    
getChildren                      
getChildrenCount : n_children             
getClass                         
getConverterContextAt            
getEditorContextAt               
getGroup                         
getItem                          
getLevel                         
getLoadedVerticalAttributeCount  
getLoadedVerticalAttributes      
getNextSibling                   
getNumberOfVisibleChildren       
getNumberOfVisibleExpandable     
getParent                        
getPreviousSibling               
getPropertyChangeListeners       
getTreeTableModel                
getValueAt                       
hasChildren                      
hasVisibleChildren               
hashCode                         
isAdjusting                      
isAnyVerticalAttributeMissing    
isCellEditable                   
isExpandable                     
isExpandableStateInitialized     
isExpanded                       
moveDownChild                    
moveUpChild                      
notify                           
notifyAll                        
notifyCellUpdated                
notifyChildDeleted               
notifyChildInserted              
notifyChildUpdated               
notifyChildrenDeleted            
notifyChildrenInserted           
notifyChildrenUpdated            
postorderEnumeration             
preorderEnumeration              
removeAllChildren                
removeChild                      
removeChildren                   
removePropertyChangeListener     
reset                            
rowUpdated                       
setAdjusting                     
setChildren                      
setExpandable                    
setExpanded                      
setParent                        
setValueAt                       
toString                         
wait
%}

