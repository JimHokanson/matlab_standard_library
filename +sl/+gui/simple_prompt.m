classdef simple_prompt < sl.obj.handle_light
    %
    %
    %   This class is meant to facilitate simple gui prompts that run until
    %   some event
    
    properties
    %NOTE: We might want to add run options here ...
    
       data %Class
    end
    
    methods
        function obj = simple_prompt(fig_path,prop_value_pairs)
           obj.data = sl.gui.simple_prompt_data(prop_value_pairs);
           
           %TODO: Load figure and hide, wait until run ...
           
        end
    end
    
end

