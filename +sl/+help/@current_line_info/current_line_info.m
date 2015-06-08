classdef current_line_info < sl.obj.display_class
    %
    %   Class:
    %   sl.help.current_line_info
    
    properties
       raw_text
       is_call_resolved
       resolved_name
    end
    
    methods
        function obj = current_line_info(raw_text)
            obj.raw_text = raw_text;
        
        end
    end
    
end

