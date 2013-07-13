%understanding java trees


%javacomponent: name, pixel position, 'North',South,East,West, figure

%http://docs.oracle.com/javase/6/docs/api/javax/swing/JTree.html
% java_tree = javax.swing.JTree;
% [j,h] = javacomponent(java_tree,[50,50,200,800]);
% 
% m = java_tree.getModel;
% r = m.getRoot;
% methods(r)

tree_node = sl.gui.class.uitreenode();
wtf = sl.gui.class.uitree(gcf,'root_node',tree_node);