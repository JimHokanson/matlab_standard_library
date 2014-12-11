function helpc(class_name)
%x Returns help for the constructor of a class, instead of the class itself
%
%   helpc(class_name)
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

temp = sl.obj.getClassNameWithoutPackages(class_name);

help(sprintf('%s>%s',class_name,temp));

end