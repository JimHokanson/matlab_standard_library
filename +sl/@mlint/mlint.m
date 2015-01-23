classdef (Abstract) mlint < sl.obj.display_class
    %
    %   Class:
    %   sl.mlint
    %
    %   NOTE: I might put some static methods here as well
    %   as some notes on variables names for creating
    %   interface methods
    %
    %   This class is meant to be inherited by other classes in the
    %   sl.mlint package.
    %
    %   IDEAS
    %   ===================================================================
    %   - resolve line number and column to absolute indices
    %   - PROPS:
    %       - file path
    %       - file string
    %
    %   
    %   See Also:
    %   sl.mlint.all_msg
    %   sl.mlint.calls
    %   sl.mlint.editc
    %   
    %   sl.mlint.lex
    %   
    %   sl.mlint.tab
    %   sl.mlint.set
    
    
    %Other properties
    %--------------------------------------------
    %line_numbers
    %column_start_indices
    %
    
    
    properties
       d3 = '----   sl.mlint super props   ----';
       file_path
       
       raw_mex_string %This is the raw output of the mex function call.
       
       %raw_mex_newline_indices
       raw_mex_lines  %Each line in the file is its own line

       raw_file_string %The raw text from the file
       
       raw_file_newline_indices %[1 x n_lines]
       %Indices in the raw text of newlines
       
       raw_file_line_start_I
       
       raw_file_lines %{1 x n_lines}
       %Text of the originl file, broken up as 
    end
    
    %Get Methods ==========================================================
    methods
        %raw file methods ---------------------------
        %
        %
        %   TODO: We might want to make all of this a class
        %   with some initialization
        %
        %
        %   regexp(...,'split') I
        function value = get.raw_file_string(obj)
            value = obj.raw_file_string;
            if isempty(value)
               value = fileread(obj.file_path);
               obj.raw_file_string = value;
            end
        end
        function value = get.raw_file_newline_indices(obj)
           value = obj.raw_file_newline_indices();
           if isempty(value)
              value = strfind(obj.raw_file_string,sprintf('\n'));
              obj.raw_file_newline_indices = value;
           end
        end
        function value = get.raw_file_line_start_I(obj)
           value = obj.raw_file_line_start_I;
           if isempty(value)
              value = [1 obj.raw_file_newline_indices + 1];
              obj.raw_file_line_start_I = value;
           end
        end
        function value = get.raw_file_lines(obj)
           value = obj.raw_file_lines;
           if isempty(value)
              value = regexp(obj.raw_file_string,'\n','split');
              obj.raw_file_lines = value;
           end
        end
        %raw mex methods -------------------------------
        function value = get.raw_mex_lines(obj)
           value = obj.raw_mex_lines;
           if isempty(value)
              %??? Does the raw text always return a single
              %character for a line return?
              value = regexp(obj.raw_mex_string,'\n','split');
              obj.raw_mex_lines = value;
           end
        end
    end
    
    %Shared Methods =======================================================
    methods (Hidden)
        function I = getAbsIndicesFromLineAndColumn(obj,line_numbers,column_numbers)
           I = obj.raw_file_line_start_I(line_numbers) + column_numbers - 1;
           %I(end) = [];
           %words = arrayfun(@(x,y) obj.raw_file_string(x:y),I,I+5,'un',0);
        end
    end
end

