function new_file_path = changeFileExtension(file_path,new_extension)
%
%
%   new_file_path = sl.dir.changeFileExtension(file_path,new_extension)

%Ensure dot is present as first character
if new_extension(1) ~= '.'
   new_extension = ['.' new_extension]; 
end

[a,b] = fileparts(file_path);

new_file_path = fullfile(a,[b new_extension]);


end