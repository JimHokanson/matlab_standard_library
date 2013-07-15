classdef folder_default < sl.dir.searcher
    %
    %   Class:
    %   sl.dir.searcher.folder_default
    %
    %   See Also:
    %   sl.dir.list_methods
    %   sl.dir.filter_methods
    
    properties (Constant)
       %NOTE: We can add on here to create more ways of listing
       %directories and filtering the results. Depending on how much things
       %change we might need a different searcher, rather than more options
       %for this searcher
       OPTIONS = {
            'DIR_folders_names' 'ByName_v1' 1}
    end
    
    properties
       filter_method_use
       list_method_use
    end
    
    methods
        function obj = folder_default()
            obj@sl.dir.searcher();
            
            %Use the only option available for now ...
            obj.changeOption(1);
        end
        function full_paths = searchDirectories(obj,base_path)
           %
           %
           
           fm  = obj.filter_method_use;
           lm  = obj.list_method_use;
           opt = obj.filter_options.getStruct;
           ff  = @sl.dir.fullfileCA;
           
           %Run on base path
           %--------------------------------------------
           sub_folders = lm(base_path);
           sub_folders(fm(sub_folders,opt)) = [];
           full_paths = ff(base_path,sub_folders);
           
           %
           cur_start = 1;
           cur_end   = length(sub_folders);
           while cur_start <= cur_end
              for iFolder = cur_start:cur_end
                 cur_folder = full_paths{iFolder};
                 
                 sub_folders = lm(cur_folder);
                 if ~isempty(sub_folders)
                     sub_folders(fm(sub_folders,opt)) = [];
                     new_paths = ff(cur_folder,sub_folders);

                     full_paths = [full_paths new_paths]; %#ok<AGROW>
                 end
              end
              cur_start = cur_end + 1;
              cur_end   = length(full_paths);
           end
           
           full_paths = full_paths'; %For better display ...
        end
    end
    
end

