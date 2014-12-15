classdef simple_prompt < sl.obj.handle_light
    %
    %   Class:
    %   sl.gui.simple_prompt
    %
    %   TODO: Finish documentation of this class ...
    %
    %   This class is meant to facilitate simple gui prompts that run until
    %   some event
    %
    %   Originally written for Mendeley authentication, check that code ...
    
    properties (SetAccess = private)
        %NOTE: We might want to add run options here ...
%         gui_closed = false
%         finish_gui = false
        fig_handle
        h
        data    %struct
        
        %.setValuesToExtract()
        tags_to_extract
        props_to_assign
    end
    
    properties 
        cur_cb_gui_handle
        event_data
    end
    
    methods
        function obj = simple_prompt(fig_path,prop_value_pairs)            
            %
            %
            %   obj = simple_prompt(fig_path,prop_value_pairs)
            %
            %   Inputs:
            %   -------
            %   fig_path: string
            %       The idea is that a GUI is preconstructed before calling
            %       this code.
            %   prop_value_pairs: 
            
            %TODO: Load figure
            obj.fig_handle = hgload(fig_path);
            obj.h = guihandles(obj.fig_handle);
            
            obj.data = sl.gui.simple_prompt_data(obj.h,prop_value_pairs);
            
            setappdata(obj.fig_handle,'obj',obj); 
            
            %TODO: Set closing function 
        end
        function setCallback(obj,handle_name,callback_type,callback_function)
            %
            %
            %   EXAMPLE:
            %   ===========================================================
            %   g.setCallback('b_copy','ButtonDownFcn',@copy_to_clipboard)
            
           set(obj.h.(handle_name),callback_type,{@sl.gui.simple_prompt.CB_handler callback_function})
        end
        
        %NOTE: Might make the 
        function setValuesToExtract(obj,varargin)
            tag_prop_pairs = varargin;
            obj.tags_to_extract = tag_prop_pairs(1:2:end);
            obj.props_to_assign = tag_prop_pairs(2:2:end);
            %TODO: How to extract these in a more sensible way ?????
            %i.e. string vs numeric vs 
        end
        
        function runGUI(obj)
           uiwait(obj.fig_handle);
        end
        function finish(obj)
           obj.finalizeData();
           uiresume(obj.fig_handle);
           delete(obj.fig_handle);
        end
        function finalizeData(obj)
           w = warning('off','MATLAB:structOnObject'); 
           obj.data = struct(obj.data);
           warning(w);
        end
    end
    
    methods (Static)
        function CB_handler(h,ev,CB_function)
           obj = getappdata(gcbf,'obj');
           
           obj.cur_cb_gui_handle = h;
           obj.event_data        = ev;
           
           feval(CB_function,obj)
        end
    end
    
end

