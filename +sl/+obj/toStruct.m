function s = toStruct(obj,fields_to_remove)
%
%   s = sl.obj.toStruct(obj,*fields_to_remove)
%
%   INPUTS
%   ================================================
%   obj              : Input object to convert
%   fields_to_remove : (default '')
%

%Additional options? - ignore constants

% in.save_name = 's';  
% in = sl.in.processVarargin;

w = warning('off','MATLAB:structOnObject');
s = struct(obj);
warning(w);

if exist('fields_to_remove','var') && ~isempty(fields_to_remove)
   s = rmfield(s,fields_to_remove);
end



end