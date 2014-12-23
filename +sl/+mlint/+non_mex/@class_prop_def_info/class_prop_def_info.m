classdef class_prop_def_info
    %
    %   Class:   
    %   sl.mlint.non_mex.class_prop_def_info
    %
    %   The goal of this class to provide information about property
    %   definitions and their comments.
    %
    %   Improvements:
    %   -------------
    %   1) We could also provide get/set method links as well
    
    %{
    file_path = '/Users/jameshokanson/repos/matlab_standard_library/+sl/+mlint/tests/@unreachable_class/unreachable_class.m'
    obj = sl.mlint.non_mex.class_prop_def_info(file_path)
    %}
    
    properties
       file_path
    end
    
    methods
        function obj = class_prop_def_info(class_def_file_path)
            %
            %   obj = sl.mlint.non_mex.class_prop_def_info(class_def_file_path)
            
            obj.file_path = class_def_file_path;
            lex = sl.mlint.lex(class_def_file_path);
            keyboard
        end
    end
    
end

