classdef duplicate_info < handle
    %
    %   Class:
    %   sl.array.duplicate_info
    %
    %   Provides information on duplicates, if any
    %
    %   Returns an array, 1 for each entry
    
    %{
    info = sl.array.duplicate_info([1,2,3,4,5,6,4,2])
    
    info = sl.array.duplicate_info([1:30])
    
    info = sl.array.duplicate_info([])
    
    info = sl.array.duplicate_info({'test' 'cheese' 'why' 'cheese'})
    
    info = sl.array.duplicate_info({'test' 'cheese' 'why' 'cheese' 'why'})
    
    %}
    
    properties
        value %the duplicated value
        n_duplicates %how often it was duplicated
        indices %indices in the original data set of duplication
    end
    
    methods
        function obj = duplicate_info(array_data)
            %
            %   obj = sl.array.duplicate_info(array_data);
            %
            %   Returns an array of objects, 1 for each duplicate ...
            
            if nargin > 0
                [unique_values,uI] = sl.array.uniqueWithGroupIndices(array_data);
                duplicate_unique_values_I = find(cellfun('length',uI) > 1);
                
                n_objects = length(duplicate_unique_values_I);
                if n_objects == 0
                    obj = sl.array.duplicate_info.empty();
                else
                    
                    obj(1,n_objects) = sl.array.duplicate_info();
                    
                    for iObj = 1:n_objects
                        cur_obj = obj(iObj);
                        cur_unique_I = duplicate_unique_values_I(iObj);
                        cur_obj.value = unique_values(cur_unique_I);
                        cur_obj.indices = uI{cur_unique_I};
                        cur_obj.n_duplicates = length(cur_obj.indices);
                    end
                end
            end
        end
    end
    
end

