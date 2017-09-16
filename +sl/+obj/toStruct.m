function s_objs = toStruct(objs,varargin)
%x Converts an object to a structure without throwing a warning
%
%   s_objs = sl.obj.toStruct(objs,*varargin)
%
%   This function was written because Matlab will throw a warning when
%   converting an object to a structure. This function avoids this
%   warning and provides other processing options.
%
%   "Warning: Calling STRUCT on an object prevents the object from hiding
%   its implementation details and should thus be avoided. Use DISP or
%   DISPLAY to see the visible public details of an object. See 'help
%   struct' for more information."
%
%   Outputs:
%   --------
%   s_objs : structure array
%
%   Inputs:
%   -------
%   objs : array of matlab object
%       Input objects to convert.
%   
%   Optional Inputs:
%   ----------------
%   fields_to_remove : (default '')
%   
%   See Also:
%   sl.struct.toObject

%Additional options? - ignore constants

in.builtin = true;
in.fields_to_remove = {};
in = sl.in.processVarargin(in,varargin);

n_objs = length(objs);

all_objects = cell(1,n_objs);

w = warning('off','MATLAB:structOnObject');
for iObj = 1:n_objs
    if in.builtin
        s = builtin('struct',objs(iObj));
    else
        s = struct();
    end
    
    if ~isempty(in.fields_to_remove);
        %NOTE: rmfield will throw an error if not present ...
        if ischar(in.fields_to_remove)
            in.fields_to_remove = {in.fields_to_remove};
        end
        s = rmfield(s,in.fields_to_remove);
    end
    all_objects{iObj} = s;
end
warning(w);

s_objs = [all_objects{:}];



end