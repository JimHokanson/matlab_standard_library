function dispObject_v1(objs,varargin)
%x  Displays props AND methods of an object to the cmd window
%
%   sl.obj.dispObject_v1(obj,varargin)
%
%   Optional Inputs:
%   ----------------
%   show_methods : logical
%       
%   show_handle_methods :
%   show_constructor : 
%   show_hidden : 
%   
%   Improvements:
%   -------------
%
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


in.show_methods = true;
in.show_handle_methods = false;
in.show_constructor = false;
in.show_hidden = false; %If true hidden props (NYI) and methods are shown
in = sl.in.processVarargin(in,varargin); %,'return_as_object',true);

full_class_name = class(objs);

%STEP 1: Display the class name
%------------------------------------------------
%Current format:
%
%Class [full_class_name] with properties:
%       -----------------   <= link, clicking on link edits the class
%
%
%   We have a chicken and egg problem. We want to display whether or not
%   the class has properties but this requires that we run some code that
%   comes after the class display. We could try and break things up
%   but this seems messy.
%
%   TODO: Provide option for returning text instead of displaying text

prop_display_text = sl.obj.disp.properties_v1(objs);

%Step 1: Display the class
%-------------------------
if length(objs) > 1
    sz = size(objs);
    size_string = sprintf('[%d x %d] ',sz(1),sz(2));
else
    size_string = '';
end

if isempty(prop_display_text)
    suffix_string = 'with no properties';
else
    suffix_string = 'with properties:'; 
end

fprintf(1,'Class %s %s%s\n\n',...
    h__createEditLink(full_class_name,full_class_name),...
    size_string,suffix_string);

%Property & Method display
%------------------------------------------------
disp(prop_display_text)

%I'd like to change how we're doing this ...
method_options = sl.obj.disp.methods_v1(1);
[m_in,in] = sl.in.removeOptions(in,fieldnames(method_options));

%Eventually we'll make this conditional
%TODO: Have a cutoff on the # of methods that can be displayed
%NOTE: This will first require some method filtering
if in.show_methods
    sl.obj.disp.methods_v1(objs,m_in);
end


end

function edit_link = h__createEditLink(disp_str,edit_str)

edit_cmd  = sprintf('edit %s',edit_str);
edit_link = sl.ml.cmd_window.createLinkForCommands(disp_str,edit_cmd);

end

