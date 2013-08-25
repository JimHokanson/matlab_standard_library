classdef fcn < sl.code.doc
    %
    %   Class:
    %   sl.code.fcn
    %
    %   A function document. This is meant to be specific to
    %   a standalone function. I might inherit an object method
    %   from this ...
    %
    %   Things to know:
    %   main function
    %   subfunctions
    %   other functions
    %   tree?
    %   
    %   function starts, ends
    %
    %   For any given line which function owns the line
    %
    %   for each character, is a comment, string, or something else
    %   -> useful for easy searches for characters while avoiding
    %   comments and strings
    %
    %   variable assignments
    %   
    
    %TODO: Move some of these to the superclass
    properties
        fcn_names       %[1 x n_fcns]
        fcn_types       %[1 x n_fcns]
        fcn_start_lines %[1 x n_fcns]
        fcn_end_lines   %[1 x n_fcns]
        char_type   %[1 x n_chars] For each charcter this indicates
        %if the character is part of a comment, string, or something else
        %
        %0 - other
        %1 - comment
        %2 - string
    end
    
    methods
        function obj = fcn()
           %TODO: Implement me!
           
           
           
        end
    end
    
end

