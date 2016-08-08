classdef (Hidden) stack
    %
    
    properties
    end
    
    methods (Hidden,Static)
        function goDebugHelper(stack_printout)
            %
            %   sl.stack.goDebugHelper(stack_printout)
            %
            %   This is used by goDebug.mex in order to 
            %   open the editor to the current edit point in the stack.
            %
            %   
            lines = sl.str.getLines(stack_printout);
            
            [~,is_matched] = sl.cellstr.regexpSingleMatchTokens(...
                lines,'^>','output_type','match');
            
            I = find(is_matched,1);
            
            if isempty(I)
                %TODO: Throw warning
                idx_use = 2;
            else
                idx_use = I + 1; %We need to add 
            end
            
            s = dbstack('-completenames');
            matlab.desktop.editor.openAndGoToLine(s(idx_use).file,s(idx_use).line); 
        end
    end
    
end

