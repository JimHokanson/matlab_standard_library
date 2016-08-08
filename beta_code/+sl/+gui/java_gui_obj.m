classdef (Hidden) java_gui_obj < dynamicprops
    %
    %   Class:
    %   sl.gui.java_gui_obj
    %
    %   obj@sl.gui.java_gui_obj(java_ref)
    %   
    
    properties
       j
    end
    
    methods
        function obj = java_gui_obj(java_ref)
           %
           %
           obj.j = java_ref;
        end
    end
    
end

