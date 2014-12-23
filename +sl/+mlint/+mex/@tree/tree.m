classdef tree < sl.mlint
    %
    %   Class:
    %   sl.mlint.mex.tree
    %
    %   Parse tree
    %
    %   Tells us:
    %   - where property definitons are
    
    
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
    end
    
    methods
        function obj = tree(file_path)
            %
            %   obj = sl.mlint.mex.tree(file_path)
            
            obj.file_path      = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-tree','-m3');
            
            %In order to read across multiple lines, I move each second line
            %into the first ones. I'd rather not do this but it works for
            %now.
            fixed_string = regexprep(obj.raw_mex_string,'\n\s{10,}|','    ');
            %fixed_string = regexprep(
            
            
            %0:   1/ 1    1|        CLASSDEF |   1 |   5 | 2825 |  -  |  -  |  -  |V=39929, 0/0
            %                       |             
            c = textscan(fixed_string,...
                '%f: %f/%f %f|      %[^|]   | %f | %f | %f | %f | %f | %f |    %[^\n]',...
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
            
            temp = regexp(c{12},'\s*\|\s*','split','once');
            
            obj.first_string = cellfun(@(x) x(1),temp,'un',0);
            obj.second_string = cellfun(@(x) x(2),temp,'un',0);
        end
    end
    
end

%0.87 mex
%1.67 regexprep - yikes, would like to avoid this
%1.53 textscan
%1 second each for first and second string
