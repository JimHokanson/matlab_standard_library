function helpc(class_name_or_instance)
%x Returns help for the constructor of a class, instead of the class itself
%
%   Calling Forms:
%   --------------
%   1)
%   helpc(class_name)
%   
%   2)
%   helpc class_name
%
%   3)
%   helpc(class_instance)
%
%
%   This function exists to clarify the difference between getting help for
%   a constructor versus the class itself. 99% of the time, I want help for
%   the constructor, not the class. This function provides it.
%
%   Examples:
%   ---------
%   1) helpc sci.time_series.filter.smoothing
%      
%      Compare this to help():
%      
%      help sci.time_series.filter.smoothing
%
%   See Also:
%   editc

if isobject(class_name_or_instance)
    class_name = class(class_name_or_instance);
else
    class_name = class_name_or_instance;
end

temp = sl.obj.getClassNameWithoutPackages(class_name);

%This basically says get help for the constructor of the class
help(sprintf('%s>%s',class_name,temp));

end