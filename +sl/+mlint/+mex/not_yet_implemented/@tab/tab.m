classdef tab < sl.mlint
    %
    %   Class:
    %   sl.mlint.tab
    %
    %   set-by/used-by table for all identifiers (see -edit)
    %
    %
    %   This seems to provide some information as to how things are called
    %   and who's related to who. For example, it might tell you all the 
    %   variables that are a part of a function.
    %
    %   Practically, I'm not sure how useful this class would be.
    
    %{ 
    %A bit of a snippet 
  0               <VOID> < -1>  NX  -1, P  -1, CH 400  Err 
  1                 data <  3>  NX  -1, P   0, CH 374  Cd  Class 3
  2 sl.obj.display_class <  4>  NX   1, P   0, CH  -1  Cu  Base Class 4
  3                    d <  7>  NX  -1, P   1, CH  -1  Vd  IsSet Property 7
  4                 time <  9>  NX   3, P   1, CH  -1  Vd  IsSet Property 9
  5                units < 11>  NX   4, P   1, CH  -1  Vd  IsSet Property 11
  6       channel_labels < 13>  NX   5, P   1, CH  -1  Vd  IsSet Property 13
  7              y_label < 15>  NX   6, P   1, CH  -1  Vd  IsSet Property 15
  8              history < 18>  NX   7, P   1, CH  -1  Vd  IsSet Property 18
  9              devents < 22>  NX   8, P   1, CH  -1  Vd  IsSet Property 22
 10          event_names < 28>  NX   9, P   1, CH  -1  Vd  IsSet Dependent Property Set/Pub Get/Pub 28
 11           n_channels < 30>  NX  10, P   1, CH  -1  Vd  IsSet Dependent Property Set/Pub Get/Pub 30
 12               n_reps < 32>  NX  11, P   1, CH  -1  Vd  IsSet Dependent Property Set/Pub Get/Pub 32
 13            n_samples < 34>  NX  12, P   1, CH  -1  Vd  IsSet Dependent Property Set/Pub Get/Pub 34
    
    %}

    properties
       names
       
       
       c3
       %- value is in <> following name e.g. copy <2680>
       %- value does not always increase but it might
       %  if ordered by where it came in the file (children
       %  of a method declaration come after the method declaration
       %  but an output comes before the method's name)
       %- value matches first value after in the #s that come
       %  at the end of the line
       nx
       %- value of -1 for function output Vd
       %- These values are not ordered
       %
       
       p %I believe this is a reference to the parent object
       %where the id is the line in the mex output (0 based)
       %
       %e.g.
       %14      get.event_names < 40>  NX  13, P   1, CH  17  Fd  IsSet Method 40
       %15                value < 38>  NX  -1, P  14, CH  -1  Vd  IsUsed IsSet OUT 38 44
       %
       %    14 is a method definition, 15 is the output variable name
       %    for the method in 14
       %    
       %reference to the entry in which the object is used
       %0 - top level
       ch %This appears to indicate the last row (0 based) which
       %contains children of the particular parent. This appears only
       %to occur for class and function declarations.
       types   
%         'Amb' : ambiguous??? Where did I see this???
%         'Cd' : class declaration
%         'Cu' : class usage 
%                - seen when specifying class inheritance
%                - also seen when using packages 
%         'Du' - ????
%         'Err' - only seen at first line of mex response for classes
%                 I'm not sure about functions ...
%         'Fd' - function declaration
%         'Fu' - function usage
%         'Va' - local variable????
%         'Vd' - variable declaration??? - seen for classdef property
%         'Vu' - ????? variable usage?
       type_counts
       extra_attributes
    end
    
    methods
        function obj = tab(file_path)
            %
            %   obj = sl.mlint.tab(file_path)
            %   
            
            obj.file_path = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-tab','-m3');
            
%#   name <#> NX #, P #, CH # type Stuff            
            
            c = textscan(obj.raw_mex_string,'%f %s < %f> NX %f, P %f, CH %f %s %[^\n]','MultipleDelimsAsOne',true);
            
            %{
            %Example lines:
            %--------------
397              samples <2926>  NX  -1, P 396, CH  -1  Vd  IsUsed IsSet OUT 2926 2933
398                  obj <2929>  NX 397, P 396, CH  -1  Vd  IsUsed IsSet IN 2929 2937
399                times <2930>  NX 398, P 396, CH  -1  Vd  IsUsed IsSet IN 2930 2940
400 h__getNewTimeObjectForDataSubset <1473>  NX 396, P   0, CH 408  Fd  CHUsed IsUsed IsSet 1473 2945          
            
            %}
            
            

            obj.names = c{2}';
            obj.c3    = c{3};
            obj.nx    = c{4};
            obj.p     = c{5};
            obj.ch    = c{6};
            obj.types = c{7}';
            obj.extra_attributes = regexp(c{8}',' ','split');
            
            [u,uI] = sl.array.uniqueWithGroupIndices(obj.types);
            
            %         'Amb' - ambiguous
%         'Cd' - class declaration
%         'Cu' - class usage - seen when specifying class inheritance
%         'Du' - 
%         'Err'
%         'Fd' - function declaration
%         'Fu' - function usage
%         'Va' - local variable????
%         'Vd' - variable declaration??? - seen for classdef property
%         'Vu' - variable usage
            
            s = struct('Amb',0,'Cd',0,'Cu',0,'Du',0,'Err',0,...
                'Fd',0,'Fu',0,'Va',0,'Vd',0,'Vu',0);
            
            for iField = 1:length(u)
               cur_field = u{iField};
               s.(cur_field) = length(uI{iField});
            end
            obj.type_counts = s;
        end
    end
    
end

