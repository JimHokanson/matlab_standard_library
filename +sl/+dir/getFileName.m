function file_names = getFileName(file_paths_or_object)
%x Returns the name of the file given the whole path
%
%   TODO: Documentaton unfinished
%
%   Calling Forms:
%   --------------
%   file_names = sl.dir.getFileName(file_paths)
%
%   Input:
%   ------
%   file_paths_or_object

if iscell(file_paths_or_object)
    %Find a:
    %1) \                             \\
    %2) Followed by no '\' s          [^\\]+
    %3) Until the end of the string   $
    temp = regexp(file_paths_or_object,'\\([^\\]+)$','tokens','once');
    
    %Unfortunately with tokens we will get nested cell arrays
    file_names = [temp{:}]; 
    
    if length(file_names) ~= length(file_paths_or_object)
       error('Length mismatch between input and output, the regexp parsing failed') 
    end
    
else
    if ischar(file_paths_or_object)
        [~,file_names] = fileparts(file_paths_or_object);
    elseif isjava(file_paths_or_object)
        file_names = char(file_paths_or_object.getName);
    else
        error('Unrecognized type')
    end
end
