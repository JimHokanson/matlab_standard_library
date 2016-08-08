classdef uitreenode < sl.gui.java_gui_obj
    %
    %   Class:
    %   sl.gui.class.uitreenode()
    %   
    %   http://docs.oracle.com/javase/tutorial/uiswing/components/tree.html
    %   http://docs.oracle.com/javase/6/docs/api/javax/swing/tree/TreeNode.html
    %   http://docs.oracle.com/javase/6/docs/api/javax/swing/tree/MutableTreeNode.html
    %
    %
    %   Subclasses:
    %   
    
    properties
       data    %For storage
       string  %For display
    end
    
    properties
       children %Pointers to children
       parent
    end
    
    properties
       %?? - how are these two related?????
       %They seem to be the same ...
       allow_children
       is_leaf %seems to be the same as allow_children
    end
    
    methods
        function obj = uitreenode(label)
           %
           %
           %    obj = sl.gui.class.uitreenode()
           
           str_obj = java.lang.String('<html><b>testing</b></html>');
           
           
           
           java_tree_node = javax.swing.tree.DefaultMutableTreeNode(str_obj);
           obj@sl.gui.java_gui_obj(java_tree_node);
        end
        function addNodes(node_objs)
            
        end
    end
    
end

