classdef (Hidden) list_result < sl.obj.handle_light
    %
    %   Class:
    %   sl.dir.list_result
    %
    %   This class is the returned value when you call:
    %   sl.dir.getList
    %
    %   See Also:
    %   sl.dir.getList
    %
    %   Improvements:
    %   -------------
    %   1) Get folder names at a certain depth from the root
    %   2) Get path of everything after the root folder path
    %   3) Allow additional post-result filtering
    
    properties
        method_used = '' 
        %This can specify how the listing was accomplished
        elapsed_time
        
        root_folder_path
        folder_names %{1 x n}
        folder_paths %{1 x n}
        d_folders %[1 x n] stucture array, output from the dir() function
        %
        %       name: 'ID_1_1.mat'
        %       date: '15-Jul-2013 10:46:48'
        %      bytes: 8009
        %      isdir: 0
        %    datenum: 7.3543e+05
        file_names %{1 x n}
        file_paths %{1 x n}
        d_files %[1 x n] stucture array, output from the dir() function
    end
    
    properties (Dependent)
        n_folders
        n_files
    end
    
    methods
        function value = get.n_folders(obj)
           value = length(obj.folder_names);
        end
        function value = get.n_files(obj)
           value = length(obj.file_names); 
        end
    end
end