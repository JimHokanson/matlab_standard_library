classdef to_ml
    %
    %   Class:
    %   sl.py.to_ml
    
    properties
    end
    
    methods (Static)
        function output = list_to_cellstr(list_data)
           %
           %    output = sl.py.to_ml.list_to_cellstr(list_data);
           temp = cell(list_data);
           output = cellfun(@char,temp,'un',0);
        end
    end
    
end

