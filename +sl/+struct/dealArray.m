function varargout = dealArray(array_data)
%
%   varargout = sl.struct.dealArray(array_data)
%
%   Use this function to assign elements of an array to a field in a
%   structure array.
%
%   
%   Example:
%   --------
%   [stats_objs.p_t] = sl.struct.dealArray(p_t_all);

varargout = num2cell(array_data);

end