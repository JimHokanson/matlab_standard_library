function names = getAllClassMethodNames(obj)
%
%   names = getAllClassMethodNames(obj)
%
%   Returns the names of all methods of the class
%

meta_info = meta.class.fromName(class(obj));
method_info = meta_info.MethodList;
names = {method_info.Name};

end