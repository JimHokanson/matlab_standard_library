function getCurrentFunctionName(varargin)
%x Displays the current function name (with packages) in the command window
%   
%   getCurrentFunctionName()
%
%   Optional Inputs
%   ---------------
%   clipboard: (default false)
%       If true, the result is copied to the clipboard instead of being
%       displayed in the command window.

in.clipboard = false;
in = sl.in.processVarargin(in,varargin);

e = sl.ml.editor.getInstance();
temp = e.getActiveDocument();
file_path = temp.filename;

fpi = sl.obj.file_path_info(file_path);

if in.clipboard 
    clipboard('copy',fpi.full_name);
else
    disp(fpi.full_name);
end

end

