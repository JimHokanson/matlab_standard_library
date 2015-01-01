classdef editor_views_manager < sl.obj.sl_data_singleton
    %
    %   Class:
    %   sl.project.editor_views_manager
    
    properties
       view_names
       view_instances
    end
    
    methods (Access = private)
        function obj = editor_views_manager
            
        end
        function display_names = getDisplayNames(obj)
           display_names = obj.view_names; 
        end
        function [success,new_view] = promptCreateNewView(obj)
            
        end
        function createNewView(obj,name)
            
        end
    end
    
    methods (Static)
        function output = getInstance()
           persistent local_obj
           if isempty(local_obj)
               local_obj = sl.project.editor_views_manager;
           end
           output = local_obj;
        end
    end
    
end

