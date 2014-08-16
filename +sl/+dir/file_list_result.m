classdef (Hidden) file_list_result < sl.obj.handle_light
    %
    %   Class:
    %   sl.dir.file_list_result
    %
    %   This class is the returned value when you call:
    %   sl.dir.getFilesInFolder
    %
    %   See Also:
    %   sl.dir.getFilesInFolder
    
    properties
        file_names %{1 x n}
        file_paths %{1 x n}
        dir_result %[1 x n] stucture array, output from the dir() function
        %
        %       name: 'ID_1_1.mat'
        %       date: '15-Jul-2013 10:46:48'
        %      bytes: 8009
        %      isdir: 0
        %    datenum: 7.3543e+05
    end
    
    properties (Dependent)
        n_files
    end
    
    methods
        function value = get.n_files(obj)
           value = length(obj.file_names); 
        end
    end
    
end

