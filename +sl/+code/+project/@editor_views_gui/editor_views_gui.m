classdef editor_views_gui < sl.obj.handle_light
    %
    %   Class:
    %   sl.project.editor_views_gui
    
    %Tags
    %---------------------------------------------
    %pm_view_options
    %lb_file_list
    %pb_new_view
    
    properties
       fig_handle
       h
    end
    
    properties (Dependent)
       ev_view_man %Better to have a loose association???
    end
    
    methods
        function value = get.ev_view_man(~)
           value = sl.project.editor_views_manager.getInstance();
        end
    end
    
    methods
        function obj = editor_views_gui()
       
            obj.fig_handle = hgload(obj.getFigPath);
            obj.h = guihandles(obj.fig_handle);
            setappdata(obj.fig_handle,'obj',obj);   
            keyboard
            
            %View List
            %--------------------------------------
            obj.updateViewList();
            
            %New view
            %--------------------------------------
            new_view_handle = obj.h.pb_new_view;
            set(new_view_handle,'Callback',@obj.cb_newView);
        end
    end
    
    %Display updates
    methods
        function updateViewList(obj)
           set(obj.h.pm_view_options,'String',obj.ev_view_man.getDisplayNames)
        end
    end
    
    
    methods (Static)
        function fig_path = getFigPath()
           temp     = sl.dir.getMyBasePath;
           fig_path = fullfile(temp,'main.fig');
        end
    end
    
    %Callbacks
    %----------------------------------------------------------------------
    methods (Static)
        function cb_newView(~,~)
           obj = getappdata(gcbf,'obj');
           
           %TODO: Ask manager to create a new view
           
           %TODO: Update string display accordingly ...
           obj.updateViewList();
        end
    end
    
end

