classdef calling_function_info < sl.obj.handle_light
    %
    %   Class:
    %   sl.stack.calling_function_info
    %
    %
    %   Status:
    %   I am still working on this code
    
    
    properties
       line_number
       file_path
       name
    end
    
    methods
        
        function obj = calling_function_info(level)
            %getCallingFunction  Returns the caller of the calling function.
            %
            %
            %   TODO:
            %   1) Update documentation
            %   2)
            %
            %
            %
            %
            %   [FUNCTION_NAME, FILE, LINE] = sl.stack.getCallingFunction(*level)
            %
            %   Use this function to tell what function is calling your function.
            %
            %   INPUTS
            %   =========================================================================
            %   level - (numeric) default: 1, which caller to retrieve, where 1 denotes
            %   the parent, 2 denotes grandparent:
            %       Call Tree:
            %         grandparent ( level 2 )
            %           -> parent ( level 1 )
            %             -> child
            %   OUTPUTS
            %   =========================================================================
            %   functionName - (char) name of calling function of 'CommandWindow_Or_Script'
            %       if the function was called from the command window or an mfile
            %       script
            %   file         - (char) filepath
            %   line         - (numeric) calling line number
            %
            %   Example:
            %   ========================================
            %   If function2 calls function1, and function1 calls getCallingFunction()
            %   then the output FUNCTION_NAME would be function2, indicating that
            %   function1's caller is function2.
            %   Call Tree:
            %     function2
            %     -> function1
            %       -> getCallingFunction
            %
            % tags: utility, display
            
            if nargin < 1
                level = 1;
            end
            if level < 1
                formattedWarning(' ''level'' must be > 0 ');
                level = 1;
            end
            file = [];
            line = [];
            s    = dbstack('-completenames');
            if length(s) == 1
                error('This function should be called from a function')
            elseif length(s) == 2
                functionName = 'CommandWindow_Or_Script';
            else
                idx = min(3+level-1,length(s));
                functionName = s(idx).name;
                if nargout > 1
                    file = s(idx).file;
                    if nargout > 2
                        line = s(idx).line;
                    end
                end
            end
            
        end
        
        
        
        
        
    end
    
end

