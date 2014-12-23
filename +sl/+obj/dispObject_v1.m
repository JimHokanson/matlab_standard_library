function dispObject_v1(objs,varargin)
%x  Displays props AND methods of an object to the cmd window
%
%   sl.obj.dispObject_v1(obj,varargin)
%
%   Improvements:
%   -------------
%   1) TODO: Fix edit links for properties so that they go to the property
%   instead of just opening the class. This may require a bit of mlint
%   help.
%
%   2) TODO: Allow not showing dependent properties. Todo this right I
%   think it will be important to have a comment markup system which
%   indicates not to show a property, rather than disabling display of 
%   all dependent properties. 
%       Note, if the value has already been computed, we could display
%   the value. This would require something that indicates the value has
%   already been computed. To handle this properly, it might be good have a
%   system that handles whether or not these values have been computed.
%
%   3) TODO: Allow showing by class (i.e. have indicator from
%   parent)
%
%   Method Prefixes (NYI) - goal is to prefix methods
%   with indicators as to the type ...
%   ==================================================
%   s - static
%   h - normally hidden
%   i - inherited
%
%
%   Improvements:
%   -------------
%   1) Can we determine if this is called from code and/or the command
%   window or from the mouse over. If we know it is is from a mouseover
%   then we don't want to display any links. We might be able to do this if
%   we can detect that the command window is busy ...


in.show_handle_methods = false;
in.show_constructor = false;
in.show_hidden = false; %If true hidden props (NYI) and methods are shown
in = sl.in.processVarargin(in,varargin);

full_class_name = class(objs);

%STEP 1: Display the class name
%------------------------------------------------
%Current format:
%Class: [full_class_name]
%       -----------------   <= link, clicking on link edits the class

%STEP 1: Get property info
%-------------------------
[all_spaces,all_names,all_values] = h__getPropParts(objs);

n_properties = length(all_spaces);

%Step 2: Display the class
%-------------------------
if length(objs) > 1
    sz = size(objs);
    size_string = sprintf('[%d x %d] ',sz(1),sz(2));
else
    size_string = '';
end

if n_properties == 0
    suffix_string = 'with no properties';
else
    suffix_string = 'with properties:'; 
end

fprintf(1,'Class %s %s%s\n',...
    h__createEditLink(full_class_name,full_class_name),...
    size_string,suffix_string);


%Part 2: Display each property
%--------------------------------------
for iProp = 1:n_properties
    %TODO: This doesn't work as intended. In 2013a mac it brings
    %up the class, not the property.
    cur_prop_name = all_names{iProp};
    leading_space = all_spaces{iProp};
    
    
    full_prop_name = sprintf('%s.%s',full_class_name,cur_prop_name);
    edit_link = h__createEditLink(cur_prop_name,full_prop_name);
    if length(objs) > 1
        fprintf(1,'%s%s\n',leading_space,edit_link);
    else
        cur_prop_str  = all_values{iProp};
        fprintf(1,'%s%s:%s\n',leading_space,edit_link,cur_prop_str);
    end
end

%
%
%ci = sl.help.class_methods(full_class_name);

%Eventually we'll make this conditional

sl.obj.dispMethods_v1(objs,in);

%TODO: Have a cutoff on the # of methods that can be displayed
%NOTE: This will first require some method filtering




%Method Display
%------------------------------------------------------------------
end

function edit_link = h__createEditLink(disp_str,edit_str)

edit_cmd  = sprintf('edit %s',edit_str);
edit_link = sl.cmd_window.createLinkForCommands(disp_str,edit_cmd);

end

function [all_spaces,all_names,all_values] = h__getPropParts(objs)
%The current approach grabs the default display and then adds on
%edit links.
%
%TODO: Eventually it would be good to write our own property display
%methods instead of extracting the displays from Matlab. This would
%allow us to not evaluate certain properties if they are time consuming.
%We'll do this one we get the markup language in place


%The default display is something like:
%
%   data with properties:
%
%       d: [4001x1 double]
%    time: [1x1 sci.time_series.time]

default_disp_str = evalc('builtin(''disp'',objs)');
lines = sl.str.getLines(default_disp_str);

%Note, we can't remove empty lines as it might be part of a multi-line
%display.
%1) Class display line
%2) spacer line
%end-1:end - end of the display is padded with 2 empty lines
lines([1:2 end-1:end]) = [];

multiple_objs = length(objs) > 1;

%NOTE: We are assuming that no property display is ever more
%than one line.
%Unfortunately it turns out that this is not always true. The code below
%has been rewritten to make 2 passes.
%
%Grab:
%1) leading spaces
%2) property name
%3) property display value string
if multiple_objs
    %Multiple objects, we only display the leading space
    %and property name
    temp = regexp(lines,'(\s+)([^:]*)','tokens','once');
else
    temp = regexp(lines,'(\s+)([^:]*):(.*)','tokens','once');
end

%Part 1: Grab all the components
%-------------------------------------
n_lines = length(lines);

if multiple_objs
    all_spaces = cellfun(@(x)x{1},temp,'un',0);
    all_names  = cellfun(@(x)x{2},temp,'un',0);
    all_values = []; %Not used
else
    
    last_valid_line = 0;
    is_valid = true(1,n_lines);
    all_spaces = cell(1,n_lines);
    all_names  = cell(1,n_lines);
    all_values = cell(1,n_lines);
    
    for iProp = 1:n_lines
        cur_set  = temp{iProp};
        if isempty(cur_set)
            %Add on value to previous entry
            is_valid(iProp)  = false;
            last_valid_value = all_values{last_valid_line};
            all_values{last_valid_line} = sprintf('%s\n%s',last_valid_value,lines{iProp});
        else
            all_spaces{iProp} = cur_set{1};
            all_names{iProp}  = cur_set{2};
            all_values{iProp} = cur_set{3};
            
            last_valid_line   = iProp;
        end
    end
    
    all_spaces(~is_valid) = [];
    all_names(~is_valid)  = [];
    all_values(~is_valid) = [];
end
end