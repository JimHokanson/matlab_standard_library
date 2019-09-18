classdef table_row < handle
    %
    %   Class:
    %   sl.ml.current_folder_viewer.table_row
    %
    %   Matlab Classes
    %   --------------
    %   com.jidesoft.grid.Row <= not seen in testing
    %   com.mathworks.widgets.grouptable.GroupingTableRow
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
    

    properties
       d0 = '----- read only -----' 
       debug
       exp_debug
    end
    properties (Dependent)
        level
        is_expandable
        
        n_visible_children
        %This is the # of immediate descendants that are visible
        
        n_visible_ends
        %This is the # of descendants which terminate
        %
        %   Termination incldues:
        %   1) files
        %   2) folders that are not expanded
        %
        %   An expanded folder is not counted in this list ...
        
        %item info
        %-------------
        is_folder
        is_os_directory
        is_real
        is_zip_or_jar
        name
        size
        location %com.mathworks.matlab.api.explorer.FileLocation
        
    end
    
    properties
       d1 = '----- read/write ----' 
    end
    properties (Dependent)
       expanded 
    end

    methods
        function value = get.level(obj)
           value = double(obj.h.getLevel); 
        end
        function value = get.is_expandable(obj)
            %In 2018b this is true for an empty folders and possibly
            %other things as well
            
            %Apparently, for a non-expandable folder the children count is
            %at 0, whereas for expandable folders, it is at 1 when closed
            %
            %   Nope: this depends on a race condition ...
            %
            %   value = obj.is_folder && obj.h.getChildrenCount ~= 0;
            %
            %   
            
            %Nope, race condition
            %-----------------------------
%             if obj.is_folder
%                 wtf = obj.h.breadthFirstEnumeration;
%                 w1 = wtf.nextElement;
%                 value = wtf.hasMoreElements;
%                 w2 = wtf.nextElement;
%                 obj.exp_debug = {obj.is_folder w2};
%             else
%                 value = false;
%             end
            
          	if obj.is_folder
                d = char(obj.location.toString);
                temp = dir(d);
                value = length(temp) > 2;
                obj.exp_debug = {obj.is_folder length(temp)};
            else
                value = false;
            end
            
%             
            
%             
            %value = obj.h.isExpandable;
        end
        function value = get.expanded(obj)
            value = obj.is_expandable && obj.h.isExpanded;
        end
        function set.expanded(obj,value)
            %http://www.jidesoft.com/javadoc/com/jidesoft/grid/AbstractExpandable.html#setExpanded(boolean)
            
            if value == obj.expanded
                keyboard
                obj.debug = 'short';
               return 
            end
            
            if ~obj.is_expandable
                %Design decision, allow to be ok for folders
                if obj.is_folder
                    obj.debug = 'fail';
                    return
                end
                error('Unable to set this for non-expandable objects')
            end
            
            if ~islogical(value)
                error('expansion value must be of type logical')
            end
            
            nav_table = handle(obj.t.getNavigableModel());
            %This approach is recommended as it notifies the tree model
            %as opposed to using setExpand for the row
            if value
                obj.debug = 'entered';
                %Note, dir will list hidden files but the display
                %won't necessarily show them, so we can't wait for match
                %d = dir();
                %
                
                %https://www.mathworks.com/matlabcentral/answers/479982-waiting-for-current-folder-viewer-to-expand
                
                folder_path = char(obj.location.toString);
                
                dir_names = sl.dir.listNonHiddenFolders(folder_path,'keep_files',true);
                
                n_in_dir = length(dir_names);
                
                n_rows1 = nav_table.RowCount; 
                n_target = n_rows1 + n_in_dir;
                nav_table.expandRow(obj.h,true);
                %Note, at this point in the code we know we can expand
                %because we have excluded non-expandable folders
                
                %Wait for the first expansion ...
                while n_rows1 == nav_table.RowCount
                    pause(0.01);
                end
                
%                 n_rows = nav_table.RowCount;
%             	for i = 1:100
%                     pause(0.25)
%                     n2 = nav_table.RowCount();
%                     if n2 == n_rows
%                        break 
%                     end
%                     n_rows = n2;
%                 end

                h_tic = tic;
                h2 = obj.h;
                c = h2.getChildAt(n_in_dir-1);
                while isempty(c)
                   pause(0.01)
                    if toc(h_tic) > 5
                        error('expansion timed out')
                    end
                    c = h2.getChildAt(n_in_dir-1);
                end
                
                obj.debug = {'this is c' c};
                
                %{
                n_rows = nav_table.RowCount;
                %Wait for any more expansion ...
                t_last = tic;
                while true
                    pause(0.02);
                    n2 = nav_table.RowCount;
                    if n2 >= n_target
                        %For Windows .git is hidden but
                        %the explorer shows it, so we end up going over
                        %
                        %TODO: On windows we need to determine if we are
                        %hiding files or not ...
                        disp('hit target')
                        break
                    elseif n2 ~= n_rows
                        n_rows = n2;
                        t_last = tic;
                    elseif toc(t_last) > 5
                        %Here we assume that we can add a row
                        %in 200 ms ...
                        break
                    end
                end
                %}
                
                %This appears to return too early
                %need to presumably wait for last child to be valid
%                 c = h2.getChildAt(1);
%                 while isempty(c)
%                     pause(0.01)
%                     if toc(t) > 5
%                         error('expansion timed out')
%                     end
%                     c = h2.getChildAt(1);
%                 end
            else
                obj.debug = 'nope';
                nav_table.expandRow(obj.h,false);
                %Do we want to pause ...
            end
                
            
%             gtm = handle(obj.t.getNavigableModel());
%             n_rows = gtm.RowCount;
%             gtm.expandRow(obj.h,value);
%             
%             %This isn't ideal, we need some way of blocking
%             %- basically this just waits for a bit, and if the # of rows
%             %  is still changing, waits a bit more
%             for i = 1:100
%                 pause(0.25)
%                 n2 = gtm.RowCount();
%                 if n2 == n_rows
%                    break 
%                 end
%                 n_rows = n2;
%             end
% %               for i = 1:100
% %                   pause(0.01)
% %                   disp(gtm.isAdjusting)
% %               end
% %             obj.h.setExpanded(value);
% %             pause(1)
        end
        function value = get.n_visible_children(obj)
            if obj.expanded
                value = double(obj.h.getNumberOfVisibleChildren); 
            else
                value = 0;
            end
        end
        function value = get.n_visible_ends(obj)
            %TODO: This is deprecated
            %http://www.jidesoft.com/javadoc/com/jidesoft/grid/AbstractExpandable.html#getAllVisibleChildrenCount()
            if obj.expanded
               value = double(obj.h.getAllVisibleChildrenCount);
            else
               value = 0; 
            end
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
            %
            %   Inputs
            %   ------
            %   t : com.mathworks.mlwidgets.explorer.widgets.table.FileTable
            obj.h = h;
            obj.t = t;
            obj.item = h.getItem();
%             if obj.is_folder && ~obj.is_expandable
%                 obj.expanded = false;
%             end
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
getAllChildrenCount(boolean)
      %true => leaf only
      %false => 
getAllVisibleChildrenCount     %n_visible_ends  

getCellClassAt                   
getChildAt                       
getChildIndex                    
getChildren                      
getChildrenCount : n_children             
getClass                         
getConverterContextAt            
getEditorContextAt               
getGroup                         
getItem  : properties of the item are exposed                        
getLevel : level                        
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

