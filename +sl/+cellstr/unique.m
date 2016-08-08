classdef unique < sl.array.unique_super
    %
    %   Class:
    %   sl.cellstr.unique_rows
    %
    %   This class is meant to be able to provide more information about a
    %   unique set of rows than is tranditionally given from
    %   unique(,'rows'). It does this by holding onto intermediate values
    %   during the sorting process.
    %
    %   Improvements:
    %   -------------------------------------------------------------------
    %   1) On strcmp, have try/catch in case not a cellstr
    
    properties (Constant,Hidden)
        SORT_FUNCTION_HANDLE = @sort
        IS_DIFFERENT_HANDLE  = @sl.cellstr.unique.isDifferent
        IS_2D = false
    end
    
    methods
        function obj = unique(data)
            obj@sl.array.unique_super(data);
        end
    end
    
    methods (Hidden,Static)
        function mask = isDifferent(data)
            %
            %    mask = sl.array.unique_rows.isDifferent(matrix_data)
            
            mask = ~strcmp(data(1:end-1),data(2:end));
        end
        function hidden_test_function()
            temp = sl.cellstr.unique({'this' 'is' 'a' 'test'});
            keyboard
        end
    end
end

