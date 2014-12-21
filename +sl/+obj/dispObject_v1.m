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
%
%
%   Improvements:
%   -------------
%   1) Can we determine if this is called from code and/or the command
%   window or from the mouse over. If we know it is is from a mouseover
%   then we don't want to display any links. We might be able to do this if
%   we can detect that the command window is busy ...
%   
%   
%

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

%Display the class name
%--------------------------
%Current format:
%Class: [full_class_name]
%       -----------------   <= link, clicking on link edits the class
full_class_name = class(objs);
fprintf(1,'Class: %s\n',h__createEditLink(full_class_name,full_class_name));

%Display the properties
%----------------------
%The current approach grabs the default display and then adds on
%edit links.

%Grab the default display and break down into property strings
%
%
%This is something like:
%   data with properties:
% 
%       d: [4001x1 double]
%    time: [1x1 sci.time_series.time]

default_disp_str = evalc('builtin(''disp'',objs)');
lines = sl.str.getLines(default_disp_str);
lines(cellfun('isempty',lines)) = [];
%Remove the class display line (always first)
lines(1) = [];

if ~isempty(lines)
    fprintf(1,'with properties:\n');
end

%TODO: Make sure we can handle an array of objects

%NOTE: We are assuming that no property display is ever more
%than one line ...
%Grab:
%1) leading spaces
%2) property name
%3) property display value string
temp = regexp(lines,'(\s+)([^:]*):(.*)','tokens','once');
for iProp = 1:length(lines) 
   cur_set  = temp{iProp};
   leading_space = cur_set{1};
   cur_prop_name = cur_set{2};
   cur_prop_str  = cur_set{3};
   
   %TODO: This doesn't work as intended. In 2013a mac it brings
   %up the class, not the property.
   full_prop_name = sprintf('%s.%s',full_class_name,cur_prop_name);
   edit_link = h__createEditLink(cur_prop_name,full_prop_name);
   fprintf(1,'%s%s:%s\n',leading_space,edit_link,cur_prop_str);
end

%
%
%ci = sl.help.class_methods(full_class_name);

%Eventually we'll make this conditional

sl.obj.dispMethods_v1(objs);

%TODO: Have a cutoff on the # of methods that can be displayed
%NOTE: This will first require some method filtering




%Method Display
%------------------------------------------------------------------
end

function edit_link = h__createEditLink(disp_str,edit_str)

edit_cmd  = sprintf('edit %s',edit_str);
edit_link = sl.cmd_window.createLinkForCommands(disp_str,edit_cmd);

end