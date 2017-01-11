classdef merge_from_cell_result
    %
    %   Class:
    %   sl.array.objs.merge_from_cell_result
    %
    %   See Also:
    %   ---------
    %   sl.array.mergeFromCells
    
    properties
        n_each
    end
    
    properties (Dependent)
        labels 
    end
    
    methods
        function value = get.labels(obj)
           value = sl.array.genFromCounts(obj.n_each,1:length(obj.n_each)); 
        end
    end
    
    methods
        function obj = merge_from_cell_result(n_each)
            obj.n_each = n_each;
        end
    end
    
end

