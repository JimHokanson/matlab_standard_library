classdef (Hidden) modules
    %
    %   Class
    %   sl.modules
    %
    
    %{
        Tasks
        ----------
        1) Determine if the modules exist
    %}
    
    properties (Constant)
        modules_folder_name = 'matlab_sl_modules'
        module_remotes = {...
            'https://github.com/JimHokanson/plotBig_Matlab',
            'https://github.com/JimHokanson/libgit2_matlab'}
    end
    
    properties (Dependent)
        module_names
    end
    
    methods
        function value = get.module_names(obj)
            [~,value] = cellfun(@fileparts,obj.module_remotes,'un',0);
        end
    end
    
    methods (Static)
        function initialize()
            %
            %   sl.modules.initialize()
            
            if ~sl.git.is_installed
                sl.warning.formatted('Git not installed, unable to download and/or update modules');
                return
            end
            
            %1) Get the path to the modules folder
            %2) If missing, create that path
            %3) Determine if the modules are present
            %4) If not present, then clone (later we can download instead)
            %5) Add the modules to the path ...
            
            obj = sl.modules;
            
            root_path = sl.stack.getPackageRoot();
            parent_path = fileparts(root_path);
            modules_root_path = fullfile(parent_path,obj.modules_folder_name);
            sl.dir.createFolderIfNoExist(modules_root_path);
            
            %Get the folders
            module_names_local = obj.module_names;
            module_remotes_local = obj.module_remotes;
            for iModule = 1:length(module_names_local)
                cur_module_name = module_names_local{iModule};
                module_folder_path = fullfile(modules_root_path,cur_module_name);
                if ~exist(module_folder_path,'dir')
                    cur_remote_address = module_remotes_local{iModule};
                    fprintf('Cloning %s ...',cur_remote_address);
                    sl.git.clone(module_remotes_local{iModule},fileparts(module_folder_path));
                    fprintf('Done\n');
                end
                
                sl.path.addPackages(module_folder_path);
                
                %TODO: Pull
                %Notify if a pull is necessary (i.e. we are out of date)
                %Provide a link to a module GUI
                
                %TODO: Initialize if need be ...
                
            end
        end
        
    end
    
end

