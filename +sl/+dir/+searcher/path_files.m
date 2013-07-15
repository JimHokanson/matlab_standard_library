classdef path_files < sl.dir.searcher
    %
    %
    %   This searcher should search for executable files in the path
    %
    %   RULES:
    %   -------------------------------------------------------------------
    %   +package -> exposes one directory below it, the package prefix
    %   needs to be kept
    %   @class   -> for right now we'll look stop at these directories
    %           NOTE: The directory itself needs to be kept
    %
    %   what() - 
    %
    %   See Also:
    %   sl.dir.searcher.folder_default
    
    properties
    end
    
    methods
        function file_list = searchDirectories(obj,base_path)
           %Single or multiple files????? 
        end
    end
    
end

