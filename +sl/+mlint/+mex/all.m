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
    %
    %   See Also:
    %   sl.mlint.calls
    %   sl.mlint.lex
    %   sl.mlint.tab
    
    properties
        file_path
    end
    
    properties
        all_msg %sl.mlint.all_msg
    end
    
    properties
        calls %sl.mlint.calls
        lex %sl.mlint.lex
        tab
        editc
    end
    
    methods
        function value = get.calls(obj)
            value = obj.calls;
            if isempty(value)
                value = sl.mlint.calls(obj.file_path);
                obj.calls = value;
            end
        end
        function value = get.lex(obj)
           value = obj.lex;
           if isempty(value)
              value = sl.mlint.lex(obj.file_path);
              obj.lex = value;
           end
        end
        function value = get.tab(obj)
           value = obj.tab;
           if isempty(value)
               value   = sl.mlint.tab(obj.file_path);
               obj.tab = value;
           end
        end
        function value = get.editc(obj)
            value = obj.editc;
            if isempty(value)
                value = sl.mlint.editc(obj.file_path);
                obj.calls = value;
            end
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

