classdef (Hidden) list_methods
    %
    %   Class:
    %   sl.dir.list_methods
    %
    %   This should be reorganized. These are static methods that can be
    %   used to enumerate the contants of a directory ...
    %   
    %
    %   The idea is to expand the list methods with other options which
    %   return more data like data modified and attributes (size, hidden,
    %   etc)
    %
    %   Improvements:
    %   -------------------------------------------------------------------
    %   1) Incorporate mex solutions ...
    %   2) Need to implement testing suite along with speed testing support
    %   framework ...
    %
    %   See Also:
    %   sl.dir.searcher
    %   sl.dir.filter_methods
    %   sl.dir.filter_options
    %   
    %
    
    
    %Other list methods:
    %
    % Windows c++:
    % #include <io.h>
    % #include <direct.h>
    %   getcwd
    %    
    % #include <sys/types.h>  // For stat().
    % #include <sys/stat.h>   // For stat().
    %   
    
    
    methods (Static)
        function full_paths = DIR_folders_fullpath(base_path)
            %
            %    full_paths = h__DIR_fullpath_folders_only(base_path)
            %
            
            import sl.dir.list_methods
            
            folder_names = list_methods.DIR_folders_names(base_path);
            full_paths   = sl.dir.fullfileCA(base_path,folder_names);
        end
        function folder_names = DIR_folders_names(base_path)
            %
            %    folder_names = h__DIR_fullpath_folders_only(base_path)
            %
            %    Important Impementation Notes:
            %    1) Returns full file paths
            %    2) Uses dir method
            %    3) Removes . and .. directories ...
            
            d            = dir(base_path);
            all_names    = {d.name};
            folder_names = all_names([d.isdir]);
            if length(folder_names) > 2 && strcmp(folder_names{1},'.') && strcmp(folder_names{2},'..')
                %Often (but not always) the first two elements are '.' and '..'
                %The outputs are actually sorted ...
                %Not sure if this is a windows or matlab thing ...
                folder_names(1:2) = [];
            else
                %NOTE: strcmp is faster than ismember when one of the sets,
                %in this case {'.' '..'} is small ...
                folder_names(strcmp(folder_names,'.'))  = [];
                folder_names(strcmp(folder_names,'..')) = [];
            end
        end
    end
end



