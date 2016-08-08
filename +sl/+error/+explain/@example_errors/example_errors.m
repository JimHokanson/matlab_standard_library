classdef (Hidden) example_errors < sl.obj.handle_light
    %
    %   Class:
    %   sl.error.explain.example_errors
    %
    %   The goal of this file is to create example errors by which to test
    %   the explain functionality.
    %
    %   Testing Code:
    %   --------------------------------------------
    %   dbstop if error
    %   temp = sl.error.explain.example_errors;
    %   
    
    properties
    end
    
    methods (Static)
        function test_MATLAB__nonExistentField()
            %msg = 'Reference to non-existent field 'a'.'
            %'MATLAB:nonExistentField'
            a = 1;
            b = 2;
            s = struct;
            s.c = 3;
            disp(s.a)
        end
        function test_MATLAB__m_unbalanced_parens
           %
           %
           %eval('save(sl.stack.grabWorkspaceHelper(false)');
           a = 1;
           b = eval('a(2'); %Not sure how to get this error w
           
           %Help:
           %),},] missing
           %- it should be possible to be more specific as to type missing
        end
        %b = a(2   => 'MATLAB:m_improper_grouping'
        %In this case we need to 
    end
    
end

