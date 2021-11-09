classdef class_prop_def_info
    %
    %   Class:   
    %   sl.mlint.class_prop_def_info
    %
    %   The goal of this class to provide information about property
    %   definitions and their comments.
    %
    %   Improvements:
    %   -------------
    %   1) We could also provide get/set method links as well
    
    %{
    file_path = '/Users/jameshokanson/repos/matlab_standard_library/+sl/+mlint/tests/@unreachable_class/unreachable_class.m'
    obj = sl.mlint.class_prop_def_info(file_path)
    %}
    
    properties
       file_path
    end
    
    methods
        function obj = class_prop_def_info(class_def_file_path)
            %
            %   obj = sl.mlint.class_prop_def_info(class_def_file_path)
            %  
            %   Examples
            %   --------
            %   file_path = which('sl.plot.subplotter');
            %   obj = sl.mlint.class_prop_def_info(file_path);
            
            obj.file_path = class_def_file_path;
            lex = sl.mlint.mex.lex(class_def_file_path);
            keyboard
            
            %Approach:
            %1) Get property starts and ends from lex
            
            prop_I = lex.unique_types_map('PROPERTIES');
            method_I = lex.unique_types_map('METHODS');
            
            %TODO: Method ends ...
            
            end_I  = lex.unique_types_map('END');
            
            %Properties show up as names <NAME>
            %
            name_I = lex.unique_types_map('<NAME>');
            
            
            
            [I1,I2] = sl.array.indices.ofDataWithinEdges();
            
            
            %Find first end after each prop
            %prop_block_end_I = ...
            
        end
    end
    
end

