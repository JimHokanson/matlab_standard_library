classdef tree < sl.mlint
    %
    %   Class:
    %   sl.mlint.tree
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

    end
    
    methods
        function obj = tree(file_path)
            %
            %   obj = sl.mlint.tree(file_path)
            
            obj.file_path      = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-tree','-m3');
            
            keyboard
%#   name <#> NX #, P #, CH # type Stuff            
            
           % c = textscan(obj.raw_mex_output,'%f %s < %f> NX %f, P %f, CH %f %s %[^\n]','MultipleDelimsAsOne',true);

%c1 - match # (offset by 1 due to void)
%c2 - name
%c3 - length (in chars? bytes?) - 
%c4 - NX value
%c5 - P value
%c6 - CH value
%c7 - type
%c8 - extras ...

%             obj.names        = c{2}';
%             obj.c3           = c{3};
%             obj.nx           = c{4};
%             obj.p            = c{5};
%             obj.ch           = c{6};
%             obj.types        = c{7}';
%             obj.attributes   = regexp(c{8}',' ','split');
        end
    end
    
end

