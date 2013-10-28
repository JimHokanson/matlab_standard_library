function output = getFilesInFolder(folder_path,varargin)
%
%   output = sl.dir.getFilesInFolder(folder_path,varargin)
%
%   OUTPUT
%   ===================================================
%   output :
%           @type sl.dir.file_list_result
%
%           - if use_java is true, type is java.io.File[]
%
%   OPTIONAL INPUTS
%   =======================================================================
%   ext : (default ''), if not empty filters on the extension
%   use_java : (default false), if true the result uses Java, this can
%       avoid some problems with Unicode file paths. Eventually I would
%       like to have code that makes this unecessary and just works
%
%   IMPROVEMENTS
%   =======================================================================
%   1) I'd like to wrap this into the searcher objects and get rid of this
%   function in favor of a method.

in.ext = ''; %file extension
in.use_java = false;
in = sl.in.processVarargin(in,varargin);


if in.use_java
    %This bit of code was written to handle file names which were not 7-bit
    %ascii. In addition
    dir_obj    = java.io.File(folder_path);
    dir_files  = dir_obj.listFiles;
    if ~isempty(in.ext)
        if in.ext(1) == '.'
            ext_use = in.ext;
        else
            ext_use = ['.' in.ext];
        end
        
        n_files = length(dir_files);
        
        keep_mask = false(1,n_files);
        for iFile = 1:n_files
            keep_mask(iFile) = dir_files(iFile).getName.endsWith(ext_use);
        end
        
        if ~all(keep_mask)
            dir_files = dir_files(keep_mask);
        end
    end
    output = dir_files;
else
    
    if ~isempty(in.ext)
        if in.ext(1) == '.'
            ext_use = ['*' in.ext];
        else
            ext_use = ['*.' in.ext];
        end
        file_path = fullfile(folder_path,ext_use);
        temp = dir(file_path);
    else
        temp = dir(folder_path);
    end
    
    %     name
    %     date
    %     bytes
    %     isdir
    %     datenum
    
    temp([temp.isdir]) = [];
    
    output = sl.dir.file_list_result;
    
    output.file_names = {temp.name};
    output.file_paths = sl.dir.fullfileCA(folder_path,output.file_names);
    output.dir_result = temp;
    
end