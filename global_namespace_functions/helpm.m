function helpm(str)
%x  Get method help from class instance
%
%   helpm(str) OR helpm str
%
%   This is meant to provide help on a class when you are working with an
%   instance. For example, you might have:
%   
%   my_obj.prop_that_is_a_class.classMethod() 
%
%   Our goal is to get help for the method "classMethod".
%
%   The slow way:
%
%       temp = class(my_obj.prop_that_is_a_class)
%       help([temp '.classMethod'])
%
%
%   This way:
%
%       helpm my_obj.prop_that_is_a_class.classMethod
%
%
%   This function works by resolving the class name from the caller.
%
%   This function also provides a link to edit the method
%
%   Example:
%   --------
%   wtf = sci.time_series.data(rand(1e6,1),0.01);
%   helpm wtf.getDataSubset
%
%   See Also:
%   ---------
%   helpc
%   helpf


parts = regexp(str,'\.','split');

%The parent is everything except the terminal part
parent = regexprep(str,'(\.[^.]*)$','');

class_type = evalin('caller',sprintf('class(%s)',parent));

full_method_name = [class_type '.' parts{end}];

help(full_method_name)

str = sl.ml.cmd_window.createLinkForCommands('[Click to edit]',sprintf('edit %s',full_method_name));
disp(str);
