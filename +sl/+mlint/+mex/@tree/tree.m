classdef tree < sl.mlint
    %
    %   Class:
    %   sl.mlint.mex.tree
    %
    %   Parse tree
    %
    %   Tells us:
    %   - which lines property definitions are on
    
    
    %No idea what this stuff means ...
    
    %Format:
    %id: row/column #?|  name
    
    %{
    0:   1/ 1    1|        CLASSDEF |   1 |   5 | 2825 |  -  |  -  |  -  |V=39929, 0/0
                                   |
   1:   1/ 1    1|         <CEXPR> |  -  |   2 |  -  |   0 |  -  |  -  |
                                   |
   2:   1/15   15|             '<' |   3 |   4 |  -  |   1 |  -  |  -  |
                                   |
   3:   1/10   10|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | data
                                   | #1 4     ClassDef
   4:   1/17   17|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | sl.obj.display_class
                                   | #2 20     ClassRef
   5:  87/ 5 2641|      PROPERTIES |  -  |   6 |  16 |   0 |  -  |  -  |V=3000
                                   |
   6:  88/ 9 2660|             '=' |   7 |  -  |   8 |   5 |  -  |  -  |
                                   |
   7:  88/ 9 2660|          <NAME> |  -  |  -  |  -  |   6 |  -  |  -  | d
                                   | #3 1      PropDef
   8:  95/ 9
    %}
    
    
    properties
        line_numbers
        column_I
        
        absolute_I %[1 x n], Instead of a line number and column
        %index, this provides an absolute index into the string of the file
        %as to where the content starts.
        
        type
        c1
        c2
        c3
        c4
        c5
        c6
        first_string
        second_string
        
        %Some more advanced processing
        %-----------------------------
        method_def_I
        property_def_I
    end
    
    methods
        function obj = tree(file_path)
            %
            %   obj = sl.mlint.mex.tree(file_path)
            
            obj.file_path      = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-tree','-m3');
            
            %0:   1/ 1    1|        CLASSDEF |   1 |   5 | 2825 |  -  |  -  |  -  |V=39929, 0/0
            %
            
            c = textscan(obj.raw_mex_string,...
                '%f: %f/%f %f|      %[^|]   | %f | %f | %f | %f | %f | %f | %[^\n] \n | %[^\n]',...
                'MultipleDelimsAsOne',true,'treatAsEmpty', {'-'});
            
            obj.line_numbers = c{2}';
            obj.column_I = c{3}';
            obj.absolute_I = c{4}';
            obj.type = c{5};
            
            obj.c1 = c{6}';
            obj.c2 = c{7}';
            obj.c3 = c{8}';
            obj.c4 = c{9}';
            obj.c5 = c{10}';
            obj.c6 = c{11}';
            
            obj.first_string  = c{12};
            obj.second_string = c{13};
            
            %???? How can I extract out which entries have
            %MethDef and PropDef???
            %strfind on raw mex, then back out row
            
            %This entire approach is to try and avoid doing string searches
            %on all parsed entries. We need to verify that this is faster.
            
            
            %TODO: Break this up
            method_def_raw_I   = strfind(obj.raw_mex_string,' MethDef');
            
            newline_I = [0 strfind(obj.raw_mex_string,sprintf('\n')) length(obj.raw_mex_string)];
            
            property_def_raw_I = strfind(obj.raw_mex_string,' PropDef');
            
            I = sl.array.indices.ofEdgesBoundingData(method_def_raw_I,newline_I);
            obj.method_def_I = I/2;
            
            I = sl.array.indices.ofEdgesBoundingData(property_def_raw_I,newline_I);
            obj.property_def_I = I/2;
            
        end
    end
    
end

%0.87 mex
%1.67 regexprep - yikes, would like to avoid this
%1.53 textscan
%1 second each for first and second string
