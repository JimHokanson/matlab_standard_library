classdef editc < sl.mlint
    %
    %   Class:
    %   sl.mlint.editc
    %
    %   This looks a lot like 'tab' but a lot simpler. Like tab, I'm not
    %   sure how useful it actually is for what I need.
    %   
    %   Improvements
    %   ===================================================================
    %   1) Can pull out groupings
    
    properties
        d0 = '----  Processed Inputs ----'
        names           %{1 x n}
        
        grouping_ids    %[1 x n]
        %0 - in function with subfunctions, 0 seems to represent
        %function declarations ...
        %#'s groupings of functions called within the particular function
        %#'s represent the parent line
        %
        %   For example:
        % 838      FDEP_get_module   0 F  CHUsed 2322/31
        % 839                    s 838 V 
        % 840                    c 838 V 
        % 841                    m 838 V 
        % 842                   mx 838 V 
        % 843                 htag 838 V
        %   
        %   NOTE: FDEP_get_module is the subfunction ...
        
        types    %[1 x n], char
        %C - class?
        %V - variables or properties
        %  - property attribute indicates variable is a property
        %
        %F - Function
        %E - Error - first line <VOID> - not sure why this is needed ...
        
        %Would probably be better to use 
        attributes %{1 x n} containing {1 x m}
        
        %Class Attributes:
        %------------------------------------------------------------------
        % 'AllMeth'
        % 'AllProp'
        % 'Base'
        % 'Class'
        % 'DyProp'  -
        % 'Handle'  - 
        
        %Function Attributes:
        %------------------------------------------------------------------
        % ''
        % '1194/23'
        % '1237/10'
        % '663/22'
        % '945/22'
        % '968/22'
        % 'Amb'
        % 'CHSet'
        % 'CHUsed'
        % 'Ctor'     - constructor
        % 'Get/Pub'  - 
        % 'Method'   - class method
        % 'Proto'    - prototype class method
        % 'Sealed'   - 
        % 'Set/Pub'  - 
        % 'Static'   - 
        % #/# - function definition line/start column (0 based)
        %   NOTE: The columns seem to be before string interpretation
        %   so that '123\t' counts as 5 characters, not 4
        
        
        %Variable/Property
        %------------------------------------------------------------------
        % ''
        % 'CHSet'
        % 'CHUsed'
        % 'Constant'
        % 'CtorOut'
        % 'Get/Prot'
        % 'OBJ'
        % 'Property'
        % 'Set/Prot'

        
        %Class definition attributes ...
        %
        %HDS            0 C  AllProp Handle DyProp Class
        %dynamicprops   0 C  Base Class
    end
    
    properties
       c_atts
       v_atts
       f_atts
    end
    
    methods
        function value = get.c_atts(obj)
            value = obj.c_atts;
            if isempty(value)
               temp  = obj.attributes(strfind(obj.types,'C'));
               value = unique([temp{:}]);
               obj.c_atts = value;
            end
        end
        function value = get.v_atts(obj)
            value = obj.v_atts;
            if isempty(value)
               temp  = obj.attributes(strfind(obj.types,'V'));
               value = unique([temp{:}]);
               obj.v_atts = value;
            end
        end
        function value = get.f_atts(obj)
            value = obj.f_atts;
            if isempty(value)
               temp  = obj.attributes(strfind(obj.types,'F'));
               value = unique([temp{:}]);
               obj.f_atts = value;
            end
        end
    end
    
    methods
        function obj = editc(file_path)
            obj.file_path = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-edit','-m3');
            
            c = textscan(obj.raw_mex_string,'%f %s %f %s %[^\n]');

            %This is the line # of the entry (although it is off by 1
            %because the of VOID at the start)
            %
            %output_count = c{1}'; %Doesn't seem so useful
            
            obj.names        = c{2}';
            obj.grouping_ids = c{3}; 
            obj.types        = [c{4}{:}]; %
            
            remaining      = c{5}';
            obj.attributes = regexp(remaining,' ','split');
        end
    end
end

