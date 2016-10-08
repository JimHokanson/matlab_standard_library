classdef to_py
    %
    %   Class:
    %   sl.py.to_py
    
    properties
    end
    
    methods (Static)
        function python_list = cellstr_to_list(cellstr_data)
            python_list = py.list(cellstr_data);
        end
    end
    
end

