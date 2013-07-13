function s = toStruct(obj,fields_to_remove)
%
%   s = sl.obj.toStruct(obj,*fields_to_remove)
%
%   INPUTS
%   ================================================
%   obj              : Input object to convert
%   fields_to_remove : (default '')
%
%   OPTIONAL_INPUTS
%   ================================================
%   
%Additional options? - ignore constants

% in.throw_error_missing_field = true;
% in = sl.in.processVarargin;

w = warning('off','MATLAB:structOnObject');
s = struct(obj);
warning(w);

if exist('fields_to_remove','var') && ~isempty(fields_to_remove)
   %NOTE: rmfield will throw an error if not present ...
   if ischar(fields_to_remove)
       fields_to_remove = {fields_to_remove};
   end
   s = rmfield(s,fields_to_remove);
end



end