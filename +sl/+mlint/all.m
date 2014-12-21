classdef all < sl.obj.handle_light
    %
    %   Class:
    %   sl.mlint.all
    %
    %
    %   This is simply meant to facilitate quickly viewing all mlint
    %   classes relatively quickly.
    %
    %   TODO:
    %   This class should include all mlint objects ...
    
    properties
        file_path
    end
    
    properties
        all_msg %sl.mlint.all_msg
    end
    
    properties
        calls
        lex
    end
    
    methods
        function value = get.calls(obj)
            if isempty(obj.calls)
                obj.calls = sl.mlint.calls(obj.file_path);
            end
            value = obj.calls;
        end
    end
    
    methods
        function obj = all(file_path)
            %
            %   obj = sl.mlint.all(file_path)
            
            obj.file_path = file_path;
            obj.all_msg   = sl.mlint.all_msg.getInstance;
        end
    end
    
end

