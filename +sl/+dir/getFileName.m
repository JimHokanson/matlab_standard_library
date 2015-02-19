function file_names = getFileName(file_paths)
%x Returns the name of the file given the file path
%
%   This function was written to facilitate getting the name of a file
%   from the file path. It is a bit more generic than fileparts in that it
%   handles Java files or a cell array of file paths. In the latter case,
%   it does it more quickly than would be accomplished using the
%   fileparts() function (e.g. via cellfun(@fileparts)).
%
%   Calling Forms:
%   --------------
%   file_names = sl.dir.getFileName(file_paths)
%
%   file_name = sl.dir.getFileName(file_path)
%
%   file_name = sl.dir.getFileName(java_file_path)
%
%   Output:
%   -------
%   file_names : cellstr
%   file_name : char
%
%   Input:
%   ------
%   file_paths : cellstr 
%   file_path : char
%   java_file_path : java.io.File
%
%   See Also:
%   fileparts()


if iscell(file_paths)
    %Find a:
    %1) \                             \\
    %2) Followed by no '\' s          [^\\]+
    %3) Until the end of the string   $
    if ispc
        temp = regexp(file_paths,'\\([^\\]+)$','tokens','once');
    else
        temp = regexp(file_paths,'/([^/]+)$','tokens','once');
    end
    
    %Unfortunately with tokens we will get nested cell arrays
    file_names = [temp{:}]; 
    
    if length(file_names) ~= length(file_paths)
       error('Length mismatch between input and output, the regexp parsing failed') 
    end
    
else
    if ischar(file_paths)
        [~,file_names] = fileparts(file_paths);
    elseif isjava(file_paths)
        file_names = char(file_paths.getName);
    else
        error('Unrecognized type')
    end
end
