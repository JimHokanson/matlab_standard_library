classdef all < sl.obj.handle_light
    %
    %   Class:
    %   sl.mlint.mex.all
    %
    %
    %   This is simply meant to facilitate quickly viewing all mlint
    %   classes relatively quickly.
    %
    %   TODO:
    %   This class should include all mlint objects ...
    %
    %   See Also:
    %   sl.mlint.mex.calls
    %   sl.mlint.mex.lex
    %   sl.mlint.mex.tab
    
    properties
        file_path
    end
    
    properties
        all_msg %sl.mlint.mex.all_msg
    end
    
    properties
        calls       %sl.mlint.mex.scalls
        editc
        lex         %sl.mlint.mex.lex
        tab
        tree    %sl.mlint.mex.tree
        ty
        
        execution_times
    end
    
    methods
        function value = get.calls(obj)
            value = obj.calls;
            if isempty(value)
                h_tic = tic;
                value = sl.mlint.mex.calls(obj.file_path);
                temp = toc(h_tic);
                obj.execution_times.calls = temp;
                obj.calls = value;
            end
        end
        function value = get.lex(obj)
            value = obj.lex;
            if isempty(value)
                h_tic = tic;
                value = sl.mlint.mex.lex(obj.file_path);
                temp = toc(h_tic);
                obj.execution_times.lex = temp;
                obj.lex = value;
            end
        end
        function value = get.tab(obj)
            value = obj.tab;
            if isempty(value)
                h_tic = tic;
                value   = sl.mlint.mex.tab(obj.file_path);
                
                temp = toc(h_tic);
                obj.execution_times.tab = temp;
                obj.tab = value;
            end
        end
        function value = get.editc(obj)
            value = obj.editc;
            if isempty(value)
                h_tic = tic;
                value = sl.mlint.mex.editc(obj.file_path);
                temp = toc(h_tic);
                obj.execution_times.editc = temp;
                obj.editc = value;
            end
        end
        function value = get.tree(obj)
            value = obj.tree;
            if isempty(value)
                h_tic = tic;
                value = sl.mlint.mex.tree(obj.file_path);
                temp = toc(h_tic);
                obj.execution_times.tree = temp;
                obj.tree = value;
            end
        end
      	function value = get.ty(obj)
            value = obj.ty;
            if isempty(value)
                h_tic = tic;
                value = sl.mlint.mex.ty(obj.file_path);
                temp = toc(h_tic);
                obj.execution_times.ty = temp;
                obj.ty = value;
            end
        end
    end
    
    methods
        function obj = all(file_path)
            %
            %   obj = sl.mlint.mex.all(file_path)
            %
            %   Example
            %   -------
            %   obj = sl.mlint.mex.all(which('sl.plot.subplotter'));
            
            obj.file_path = file_path;
            
            h_tic = tic;
            obj.all_msg   = sl.mlint.mex.all_msg.getInstance;
            temp = toc(h_tic);
            obj.execution_times = struct('all_msg',temp);
            
        end
    end
    
end

