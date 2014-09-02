function helpm(str)
%helpm Get method help from class instance
%
%   helpm(str)
%
%   This is meant to provide help on a class when you are working with an
%   instance. For example, you might have:
%   
%   my_obj.prop_class.method() 
%   
%   class(prop_clas) = 'Class_2'
%
%   Equivalent then to: help('Class_2.method')
%
%   NOTE: This function also provides a link to edit the method


parts = regexp(str,'\.','split');

parent = regexprep(str,'(\.[^.]*)$','');

class_type = evalin('caller',sprintf('class(%s)',parent));

full_method_name = [class_type '.' parts{end}];

help(full_method_name)

str = sl.cmd_window.createLinkForCommands('[Click to edit]',sprintf('edit %s',full_method_name));
disp(str);
