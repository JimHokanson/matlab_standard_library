classdef unique < sl.array.unique_super
    %
    %   Class:
    %   sl.array.unique
    %   
    %   ???? Is this used at all?????
    %
    %   I don't think so, I'd like to delete it ...
    
    properties (Constant,Hidden)
        SORT_FUNCTION_HANDLE = @sort
        IS_DIFFERENT_HANDLE  = @sl.array.unique.isDifferent
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
            %    mask = sl.array.unique.isDifferent(matrix_data)
            
            mask = data(1:end-1) ~= data(2:end);
        end
        function hidden_test_function()
            temp = sl.array.unique(randi(10,1,1000));
            keyboard
        end
    end
    
end

