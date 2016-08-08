classdef tree_node_icons < sl.obj.handle_light
    %
    %   Class:
    %   sl.gui.class.tree_node_instance
    %
    %   
    
    properties
        
    end
    
    methods (Access = private)
        function obj = tree_node_icons()
           iconpath = [matlabroot, '/toolbox/matlab/icons/']; 
        end
    end
    
    methods (Static)
        function obj = getInstance()
           persistent p_obj
            if isempty(p_obj)
               p_obj = sl.gui.class.tree_node_instance;
            end
            obj = p_obj;
        end
    end
    
end

