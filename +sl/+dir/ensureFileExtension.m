function new_file_path = ensureFileExtension(file_path,extension)
%
%   
%   new_file_path = sl.dir.ensureFileExtension(file_path,extension)
%
%   Note: This function is not designed to change a file extension, just
%   to add it if isn't there ...
%
%   Inputs
%   =======================================================================
%   file_path : path to file
%   extension : example -> '.m'


new_file_path = file_path;

%Ensure dot is present as first character
if extension(1) ~= '.'
   extension = ['.' extension]; 
end

if ~strncmp(file_path(end:-1:1),extension,length(extension))
   new_file_path = [file_path extension]; 
end