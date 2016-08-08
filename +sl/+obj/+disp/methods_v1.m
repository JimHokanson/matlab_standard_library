function varargout = methods_v1(objs,varargin)
%x A function that displays the methods nicely
%
%   Calling Forms:
%   --------------
%   1) Call with object instances
%   
%       sl.obj.methods_v1(objs,varargin)
%
%   2) Call with object names (useful for calling from static methods)
%
%       sl.obj.methods_v1(class_name,varargin)
%   
%   3) Get the optional inputs
%   
%       option_struct = sl.obj.methods_v1(1);
%
%   
%
%   Outputs:
%   --------
%   option_struct : options for filtering options in parent
%
%
%   Optional Inputs
%   ---------------
%   header : string
%   methods_use : cellstr (default [])
%       An empty input means all methods should be used after filtering.
%       Specification of the methods to use means that the methods will be
%       displayed, regardless of the filters.
%   include_header : logical (default true)
%   show_handle_methods : logical (default true)
%
%
%   Known Bugs:
%   -----------
%   1) h1 line doesn't display properly for hidden methods
%
%
%   1) TODO: Allow showing of hidden methods via clicking on link
%
%   See Also:
%   sl.obj.getClassNameWithoutPackages
%   sl.obj.getFullMethodName

in.header = '    Methods:';
in.methods_use = []; %Empty means
in.include_header = true;
in.show_handle_methods = false;
in.show_constructor = false;
in.show_hidden = false; %If true hidden props (NYI) and methods are shown

%Early exit, options only requested?
%------------------------------------
if isnumeric(objs)
    varargout{1} = in;
    return
end

in = sl.in.processVarargin(in,varargin);


if ischar(objs)
    class_name = objs;
    meta_class_obj = meta.class.fromName(objs);
else
    class_name = class(objs);
    meta_class_obj = metaclass(objs(1));
end

meta_method_objs = meta_class_obj.MethodList;

%Method filtering
%---------------------------------------------------
if ~isempty(in.methods_use)
    if ischar(in.methods_use)
       in.methods_use = {in.methods_use}; 
    end
    method_names = {meta_method_objs.Name};
    mask = ~ismember(method_names,in.methods_use);
    
    meta_method_objs(mask) = [];
    method_names(mask)     = [];   
else

    %1) Filtering by type
    %------
    %1.1) Remove hidden
    if ~in.show_hidden
        meta_method_objs([meta_method_objs.Hidden]) = [];
    end


    %1.2) Remove handle methods
    if ~in.show_handle_methods && ~isempty(meta_class_obj.SuperclassList)
        super_class_names = {meta_class_obj.SuperclassList.Name};
        if any(strcmp(super_class_names,'handle'))
            defining_class_names = sl.cell.getStructureField({meta_method_objs.DefiningClass},'Name','un',0);
            meta_method_objs(strcmp(defining_class_names,'handle')) = [];
        end
    end


    %2) Filtering by name
    %------
    method_names = {meta_method_objs.Name};

    %2.1) Remove constructor
    if ~in.show_constructor
        class_constructor_name = sl.obj.getClassNameWithoutPackages(class_name);

        mask = strcmp(method_names,class_constructor_name);

        meta_method_objs(mask) = [];
        method_names(mask)     = [];
    end
end




%Retrieval of names to display and help text
%-------------------------------------------------
[method_names_sorted, I] = sort(method_names);
method_objs_sorted = meta_method_objs(I);

full_method_names = sl.obj.getFullMethodName(class_name,method_names_sorted);
h1_lines = cellfun(@sl.help.getH1Line,full_method_names,'un',0);

%Size setup
n_chars_max = sl.ml.cmd_window.getMaxCharsBeforeScroll();

method_names_lengths   = cellfun('length',method_names_sorted);
max_method_name_length = max(method_names_lengths);

n_methods   = length(method_names);
if n_methods == 0
    fprintf('No Methods\n')
    return
end

%TODO: Align to the method names or just have a divider????
if in.include_header
    disp(in.header);
end

%Each method will be of the form:
%   <method name>.: <method h1 line>
%such as:
%   getStore.: Retrieves info about a base unit for the TDT system

for iM = 1:n_methods
    current_method_name = method_names_sorted{iM}; %cells
    current_meta_method_obj = method_objs_sorted(iM); %arrays
    
    cur_h1_line = h1_lines{iM};
    
    %Link to edit the method
    %------------------------
    edit_cmd   = sprintf('edit(''%s'')',sl.obj.getFullMethodName(objs,current_method_name));
    colon_link = sl.ml.cmd_window.createLinkForCommands(':', edit_cmd);
       
    %Link to see the function prototype
    %----------------------------------
    period_link = h__generateFunctionPrototypeLink(current_meta_method_obj,current_method_name,class_name);
    
    %concatenation ofs the three links into one string variable
    middle_str = [period_link, ' ', colon_link];
    
    
    %% Code Phase I
    %                 % DAH Generation of a static string
    if current_meta_method_obj.Static
        static_str = '(s)';
    else
        static_str = '   ';
    end
    
    space_for_help_text = n_chars_max - max_method_name_length - 6;
    
    
    % DAH generation of the space for the string
    %                 space_for_str_text= length(SEP_STR);
    
    help_cmd         = sprintf('help(''%s'')',sl.obj.getFullMethodName(objs,current_method_name));
    method_with_link = sl.ml.cmd_window.createLinkForCommands(current_method_name,help_cmd);
    
    left_str  = sl.str.padText(method_with_link,max_method_name_length,...
        'text_loc','right','disp_len',length(current_method_name));
    
    right_str = sl.str.truncateStr(cur_h1_line,space_for_help_text,'too_short_is_ok',true);
    
    
    fprintf('%s%s %s%s\n',static_str, left_str,middle_str,right_str);
end

disp('') %Let's let things breath

end

function string_link = h__generateFunctionPrototypeLink(method_meta_obj,current_method_name,class_name)
%Use meta_methods after sorting instead

input_names  = method_meta_obj.InputNames;
output_names = method_meta_obj.OutputNames;

% need to generate this.
%                 file_pathway= mc.
% separate all the outputs with periods
%
%   function_output_string =
%   sprintf('[%s]',sl.cellstr.join(outputNames))
%
%
%   Add spaces
outputs = sl.cellstr.join(output_names);
inputs  = sl.cellstr.join(input_names);


%Use sprintf to create a string, fprintf is for displaying
%to the command window, and is not needed here
%
%   method_name ???
%
%   TODO: If static, add on path to method
if method_meta_obj.Static
    method_name_for_function_display = sprintf('%s.%s', class_name, current_method_name);  %do something here
else
    method_name_for_function_display = current_method_name;
end

string_cmd = sprintf('disp(''[%s] = %s(%s)'')', outputs, method_name_for_function_display, inputs);
string_link = sl.ml.cmd_window.createLinkForCommands('.', string_cmd);
end