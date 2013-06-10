classdef (Hidden) simple_prompt_data < dynamicprops
    %
    %   Class:
    %   sl.gui.simple_prompt_data
    %
    %   This class holds the user data for the methods as well as
    %   some additional functionality the user might desire
    
    properties (SetAccess = private)
        gui_closed = false
        finish_gui = false
        h  %gui_handles
    end
    
    methods
        function obj = simple_prompt_data(prop_value_pairs)
            %TODO: Should check to make sure we are not setting the 
            %user specific props
            for iPair = 1:2:length(prop_value_pairs)
                cur_field_name = prop_value_pairs{iPair};
                obj.addprop(cur_field_name);
                obj.(cur_field_name) = prop_value_pairs{iPair+1};
            end
        end
        %function finish_guis
    end
    
end

