classdef uitree < sl.gui.java_gui_obj
    %
    %   Class:
    %   sl.gui.class.uitree
    %
    %   http://docs.oracle.com/javase/6/docs/api/javax/swing/tree/TreeModel.html
    %   http://docs.oracle.com/javase/tutorial/uiswing/components/tree.html
    
    
    
    
    
    
    %1) Allow horizontal resizing ...
    

%              NodeDroppedCallback: []
%                  FigureComponent: [1x1 com.mathworks.mwswing.MJScrollPane]
%     NodeWillCollapseCallbackData: []
%                    SelectedNodes: []
%         NodeWillCollapseCallback: []
%                            Units: 'pixels'
%                    PixelPosition: [4x1 double]
%       NodeWillExpandCallbackData: []
%                 UserLastMethodID: 4
%            ParentFigureValidator: [1x1 com.mathworks.hg.peer.HG1FigurePeer]
%                       DndEnabled: 0
%             NodeSelectedCallback: []
%                      UIContainer: 175.0011
%                            Model: [1x1 javax.swing.tree.DefaultTreeModel]
%                             Root: []
%         NodeExpandedCallbackData: []
%                             Tree: [1x1 com.mathworks.hg.peer.utils.UIMJTree]
%            NodeCollapsedCallback: []
%                          Visible: 1
%                         Position: [4x1 double]
%           NodeWillExpandCallback: []
%                       ScrollPane: [1x1 com.mathworks.mwswing.MJScrollPane]
%             NodeExpandedCallback: []
%         NodeSelectedCallbackData: []
%        NodeCollapsedCallbackData: []
%          NodeDroppedCallbackData: []
%         MultipleSelectionEnabled: 0
%                            Class: [1x1 java.lang.Class]    
    
    properties
       root %reference to node
       root_visible
       position
    end
    
    properties
       %name get set
%        ALIAS_MAPPINGS = {
%            'root_visible' @obj.j.rootVisible 
%             }
    end
    
    methods
        function obj = uitree(parent_handle,varargin)
           %
           %    obj = sl.gui.class.uitree(parent_handle)
           %
           %    INPUTS
           %    ========================
           %    1) optional figure handle, followed by property/value pairs
           
           in.root_node = [];
           in = processVarargin(in,varargin);
           
           if ~isempty(in.root_node)
               java_tree = javax.swing.JTree(in.root_node.j);  
           else
               java_tree = javax.swing.JTree;
           end
           
           %Tree Constructors
           %--------------------------------------------------
           %() - sample model
           %(hashtable)
           %(object) ??
           %(tree model)
           %(root_node)
           %(root_node,allow_children)
           
           
           obj@sl.gui.java_gui_obj(java_tree);

           [j,h] = javacomponent(java_tree,[50,50,300,200],parent_handle); %#ok<ASGLU,NASGU>
            
           
           
           
           
        end
    end
    
end

