classdef unique_rows < sl.array.unique_super
    %
    %   Class:
    %   sl.array.unique_rows
    %
    %   This class is meant to be able to provide more information about a
    %   unique set of rows than is tranditionally given from
    %   unique(,'rows'). It does this by holding onto intermediate values
    %   during the sorting process.
    
    properties (Constant,Hidden)
        SORT_FUNCTION_HANDLE = @sortrows
        IS_DIFFERENT_HANDLE  = @sl.array.unique_rows.isDifferent
        IS_2D = true
    end
    
    methods
        function obj = unique_rows(data)
            obj@sl.array.unique_super(data);
        end
    end
    
    methods (Hidden,Static)
        function mask = isDifferent(matrix_data)
            %
            %    mask = sl.array.unique_rows.isDifferent(matrix_data)
            
            neighbor_mask = matrix_data(1:end-1,:) ~= matrix_data(2:end,:);
            mask          = any(neighbor_mask,2);
        end
        function hidden_test_function()
            temp = sl.array.unique_rows(randi(10,10000,3));
            keyboard
        end
    end
end

