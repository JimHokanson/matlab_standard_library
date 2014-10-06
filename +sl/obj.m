classdef obj
    %
    %   Class:
    %   sl.obj
    %
    
    properties
    end
    
    methods (Static)
        function name = getClassNameWithoutPackages(obj)
            %    Returns name of the class, removing package prefixes if present
            %
            %    name = sl.obj.getClassNameWithoutPackages(obj)
            %
            %    Example:
            %    --------
            %    obj = temp.package.my_object()
            %    name = sl.obj.getClassNameWithoutPackages(obj)
            %
            %    name => 'my_object'
            %
            %    %VERSUS:
            %
            %    class(obj)
            %    temp.package.my_object
            %
            
            temp_str = class(obj);
            I   = strfind(temp_str,'.');
            if isempty(I)
                name = temp_str;
            else
                name = temp_str((I(end)+1):end);
            end
        end
        function output = getFullMethodName(obj,method_name_or_names)
            %x Adds on packages and
            %
            %   output = sl.obj.getFullMethodName(obj,method_name_or_names)
            %
            %   Inputs:
            %   -------
            %   obj : Matlab Object
            %       Object from which the names should be referenced
            %   method_name_or_names :
            %
            %   Example:
            %   --------
            %   obj = adinstruments.channel()
            %
            %   m = methods(obj)
            %   m(1) => 'getAllData'
            %
            %   output = getFullMethodName(obj,'getAllData')
            %   output => 'adinstruments.channel.getAllData'
            %
            
            class_name = class(obj);
            if ischar(method_name_or_names)
                output = [class_name '.' method_name_or_names];
            else
                output = cellfun(@(x) [class_name '.' x],method_name_or_names,'un',0);
            end
        end
    end
    
    methods (Static,Hidden)
        function dispObject_v1(objs,varargin)
            %x  Displays props AND methods of an object to the cmd window
            %
            %   sl.obj.dispObject_v1(obj,varargin)
            %
            %   Design aspects:
            %   1) Have an indication of static methods by proceeding with s
            %   2) TODO: Allow showing of hidden methods via clicking on link
            %   3) TODO: Allow not showing dependent props
            %   4) TODO: Allow showing by class (i.e. have indicator from
            %   parent)
            %   5) TODO: Provide link to the definition of the methods
            %
            %   Method Prefixes (NYI) - goal is to prefix methods
            %   with indicators as to the type ...
            %   ==================================================
            %   s - static
            %   h - normally hidden
            %   i - inherited
            
            %TODO: This could be an array of objects ...
            
            %{
            %Testing code
            obj = sci.time_series.data(1:1000,0.01)
            %}
            
            %TODO: Move this to a separate file and move the "sections"
            %to their own helper methods:
            %
            % e.g. h__deleteConstructorMethod
            
            in.show_handle_methods = false;
            in.show_constructor = false;
            in.show_hidden = false; %If true hidden props (NYI) and methods are shown
            in = sl.in.processVarargin(in,varargin);
            
            
            %TODO: I think I have code that parses this ...
            %NOTE: I want to change this to display the full path ...
            %
            %   i.e.
            %   channel with properties:
            %   becomes
            %   adinstruments.channel with properties:
            %
            %TODO: Remove spacing at the end ...
            prop_str = evalc('builtin(''disp'',objs)');
            disp(prop_str)
            
            %Method Display
            %------------------------------------------------------------------
            
            
            meta_class_obj = metaclass(objs(1));
            
            meta_method_objs = meta_class_obj.MethodList;
            
            %JAH:Can be used to filter by classes ...
            % DAH: FIXED- definition_class stores the methods defining
            % class. ie. whether static or hidden, etc.
            
            
            %Method filtering
            %-------------------------------------------------
            %1) Filtering by type
            %------
            %1.1) Remove hidden
            if ~in.show_hidden
                meta_method_objs([meta_method_objs.Hidden]) = [];
            end
            
            
            %1.2) Remove handle methods
            if ~in.show_handle_methods && any(strcmp(superclasses(objs),'handle'))
                defining_class_names = sl.cell.getStructureField({meta_method_objs.DefiningClass},'Name','un',0);
                meta_method_objs(strcmp(defining_class_names,'handle')) = [];
            end
            
            
            %2) Filtering by name
            %------
            method_names = {meta_method_objs.Name}; % DAH: in a cell array
            
            %2.1) Remove constructor
            if ~in.show_constructor
                c_name = sl.obj.getClassNameWithoutPackages(objs);
                
                % DAH- I think this does what you want it to do. Not
                % entirely sure if ConstructOnLoad is zero
                
                mask = strcmp(method_names,c_name);
                
                %Alternatively, to the code below
                %mask = ~strcmp(method_names,c_name);
                %mask= (strcmp(method_names,c_name) == 0);
                
                %Two ways of filtering
                %1) method_names(mask) = []; %Remove the one we don't want
                %2) method_names = methods_names(~mask); %
                
%                 if mask == true
%                 meta_methods.DefiningClass.ConstructOnLoad= 0; 
%                 end

                meta_method_objs(mask) = [];
                
                method_names(mask) = []; %ask Jim what this line does
            end
            
            
            %Retrieval of names to display and help text
            %-------------------------------------------------
            [method_names_sorted, I] = sort(method_names);
            
            method_objs_sorted = meta_method_objs(I);
  

            %DAH how do you want me to sort these objects and for what
            %purpose

            full_method_names = sl.obj.getFullMethodName(objs,method_names_sorted);
            h1_lines       = cellfun(@sl.help.getH1Line,full_method_names,'un',0);
            
            %Size setup
            n_chars_max = sl.cmd_window.getMaxCharsBeforeScroll();
            
            method_names_lengths   = cellfun('length',method_names_sorted);
            max_method_name_length = max(method_names_lengths);
            
            
            
            n_methods   = length(method_names);
            
            if n_methods == 0
                fprintf('No Methods\n')
                return
            end
            
            fprintf('    Methods:\n');

            %{JAH
            %Each method will be of the form:
            %   <method name>.: <method h1 line>
            %such as:
            %   getStore.: Retrieves info about a base unit for the TDT
            %   system }%
            
            
            for iM = 1:n_methods
                currrent_method_name = method_names_sorted{iM}; %cells
                currrent_meta_method_obj = method_objs_sorted(iM); %arrays
                
                cur_h1_line = h1_lines{iM};
                
                % Edit link
                edit_cmd   = sprintf('edit(''%s'')',sl.obj.getFullMethodName(objs,currrent_method_name));
                colon_link = sl.cmd_window.createLinkForCommands(':', edit_cmd);
                
                % generates an class object using the static method
                % meta.class and all the information with it.
                % Also extracts input and outputnames.
                
                
                %Use meta_methods after sorting instead
        
                input_names = currrent_meta_method_obj.InputNames;
                output_names = currrent_meta_method_obj.OutputNames;
                
                % need to generate this. 
%                 file_pathway= mc.
                % separate all the outputs with periods
                %
                %   function_output_string =
                %   sprintf('[%s]',sl.cellstr.join(outputNames)
                %
                %
                %   Add spaces
                outputs =sl.cellstr.join(output_names);
                inputs =sl.cellstr.join(input_names);
         
                
                %Use sprintf to create a string, fprintf is for displaying
                %to the command window, and is not needed here
                %
                %   method_name ???
                %   
                %   TODO: If static, add on path to method
                  if currrent_meta_method_obj.Static %#note this doesn't exist yet#
                      fprintf(2,'Go to display method in sl.obj, normally I would use goDebug\n');
                      keyboard
                      method_name_for_function_display = '';  %do something here
                  else
                      method_name_for_function_display = currrent_method_name;
                  end
 
                period_cmd = sprintf('[%s] = %s(%s)', outputs, method_name_for_function_display, inputs); 
                period_link= sl.cmd_window.createLinkForCommands('.', period_cmd);
         
                
 %% Code Phase I
%                 % DAH Generation of a static string
                if currrent_meta_method_obj.Static
                    static_str= '(s)';
                else
                    static_str= ' ';
                end
                 
                % DAH concatenation ofs the three links into one string variable
                 SEP_STR= [period_link,colon_link,static_str];
                
                space_for_help_text = n_chars_max - max_method_name_length - length(SEP_STR);
                
                
                % DAH generation of the space for the string
                space_for_str_text= length(SEP_STR);
                
                help_cmd         = sprintf('help(''%s'')',sl.obj.getFullMethodName(objs,currrent_method_name));
                method_with_link = sl.cmd_window.createLinkForCommands(currrent_method_name,help_cmd);
                
                left_str  = sl.str.padText(method_with_link,max_method_name_length,...
                    'text_loc','right','disp_len',length(currrent_method_name));
                
                right_str = sl.str.truncateStr(cur_h1_line,space_for_help_text);
                
                % Generation of a middle string with a padded right side
                % (using the name and length as inputs for the provided
                % class) DAH
                middle_str= sl.str.padText(SEP_STR,space_for_str_text, ...
                    'centered');
                
                fprintf('%s%s%s\n',left_str,middle_str,right_str);
            end
            
            
        end
    end
    
end

