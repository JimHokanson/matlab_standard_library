classdef (Hidden) modules
    %
    %   Class
    %   sl.modules
    %
    %   See Also
    %   --------
    %   sl.git
    %
    
    %{
        Tasks
        ----------
        1) Determine if the modules exist
    %}
    
    properties (Constant)
        modules_folder_name = 'matlab_sl_modules'
        module_remotes = {...
            'https://github.com/JimHokanson/plotBig_Matlab'}
        
        %'https://github.com/JimHokanson/libgit2_matlab'}
    end
    
    properties
        modules_root
    end
    
    properties (Dependent)
        module_names
        module_paths
    end
    
    methods
        function value = get.module_names(obj)
            [~,value] = cellfun(@fileparts,obj.module_remotes,'un',0);
        end
        function value = get.module_paths(obj)
            value = cellfun(@(x) fullfile(obj.modules_root,x),obj.module_names,'un',0);
        end
    end
    
    methods
        function obj = modules()
            root_path = sl.stack.getPackageRoot();
            parent_path = fileparts(root_path);
            obj.modules_root = fullfile(parent_path,obj.modules_folder_name);
            sl.dir.createFolderIfNoExist(obj.modules_root);
        end
    end
    
    methods (Static)
        function initialize()
            %
            %   sl.modules.initialize()
            
            obj = sl.modules;
            
            %Currently we don't git update or check ahead/behind so
            %if the directory exists we don't need git to exist
            %
            %   This allows, for example, manual downloads
            %
            %   Expected structure:
            %   /matlab_standard_library
            %   /matlab_sl_modules
            %       /plotBig_Matlab
            %       /<other_modules>
            %   
            %   
            all_exist = true;
            module_roots = obj.module_paths;
            for i = 1:length(module_roots)
                cur_module_root = module_roots{i};
                if exist(cur_module_root,'dir')
                    sl.path.addPackages(cur_module_root);
                else
                    all_exist = false;
                    break
                end
            end
            
            %stop early, no need to continue
            if all_exist
                return
            end
            
            %TODO: Currently we don't do any git updates so
            %if the modules are downloaded we don't need to show this.
            if ~sl.git.is_installed
                sl.warning.formatted('Git not installed, unable to download modules');
                return
            end
            
            for i = 1:length(module_roots)
                cur_module_root = module_roots{i};
                if ~exist(module_roots{i},'dir')
                    cur_remote_address = obj.module_remotes{i};
                    fprintf('Cloning %s ...',cur_remote_address);
                    parent_target_dir = fileparts(cur_module_root);
                    sl.git.clone(obj.module_remotes{i},parent_target_dir);
                    fprintf('Done\n');
                    sl.path.addPackages(cur_module_root);
                end
            end
        end
        
    end
    
end

