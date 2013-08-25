classdef tab < mlintlib
    %
    %
    %
    
    

    properties
       names
       c3
       nx
       p
       %reference to the entry in which the object is used
       %0 - top level
       ch
       types   
%         'Amb'
%         'Cd'
%         'Cu'
%         'Du'
%         'Err'
%         'Fd'
%         'Fu'
%         'Va' - local variable????
%         'Vd' - variable declaration??? - seen for classdef property
%         'Vu'
       attributes
    end
    
    methods
        function obj = tab(file_path)
            
            obj.file_path = file_path;
            obj.raw_mex_output = mlintmex(file_path,'-tab','-m3');
            
%#   name <#> NX #, P #, CH # type Stuff            
            
            c = textscan(obj.raw_mex_output,'%f %s < %f> NX %f, P %f, CH %f %s %[^\n]','MultipleDelimsAsOne',true);
            
            

            
%c1 - match # (offset by 1 due to void)
%c2 - name
%c3 - length (in chars? bytes?) - 
%c4 - NX value
%c5 - P value
%c6 - CH value
%c7 - type
%c8 - extras ...

            obj.names        = c{2}';
            obj.c3           = c{3};
            obj.nx           = c{4};
            obj.p            = c{5};
            obj.ch           = c{6};
            obj.types        = c{7}';
            obj.attributes   = regexp(c{8}',' ','split');
        end
    end
    
end

