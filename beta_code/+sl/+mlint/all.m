classdef all < sl.obj.handle_light
    %
    %
    %   TODO:
    %   This class should include all mlint objects ...
    
    properties
       file_path 
    end
    
    properties
       all_msg
    end
    
    properties (Dependent)
       calls
       lex
       
    end
    
    methods
        function obj = all(file_path)
           obj.file_path = file_path;
           obj.all_msg   = sl.mlint.all_msg.getInstance;
        end
    end
    
end

