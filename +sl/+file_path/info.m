classdef info
    %
    %   Class:
    %   sl.file_path.info
    %
    %   Written to provide information about a class name from the path to
    %   the class OR ones of its method
    %
    %   See Also:
    %   sl.stack.calling_function_info
    %
    %   Improvements
    %   ------------
    
    
    properties
        is_class = false
        is_function = false
        is_class_method = false
        package_prefix
        name %class_name or function name
        class_name %only class name if found
        full_name %name with package_prefix attached
    end
    
    methods
        function obj = info(file_path)
            %.m => might be class name or method in class folder
            %
            %    obj = sl.obj.file_path_info(file_path);
            
            if ispc
                %TODO: Do error checking before indexing
                sep_type = file_path(find(file_path == '\' | file_path == '/',1,'last'));
            else
                sep_type = '/';
            end
            
            pattern = regexptranslate('escape',sep_type);
            entries = regexp(file_path,pattern,'split');
            is_package = cellfun(@(x) ~isempty(x) && x(1) == '+',entries);
            
            %check if file is .m extension and define name
            file_name_w_exten = entries{end};
            
            [~,file_name_wout_ext,file_extension] = fileparts(file_name_w_exten); %#ok<ASGLU>

            obj.name = file_name_wout_ext;
            
            I = find(is_package);
            if any(I)
                if ~isequal(I,I(1):I(end))
                    error('Packages must be sequential')
                end
                
                obj.package_prefix = sl.cellstr.join(cellfun(@(x) x(2:end),entries(I),'un',0),'d','.');
                
                next_name = entries{I(end)+1};
                
                %Remove extension if present
                [~,next_name] = fileparts(next_name);
                
                if next_name(1) == '@'
                    obj.class_name = next_name(2:end);
                    obj.is_class = true;
                    obj.is_class_method = strcmp(obj.class_name,obj.name);
                    if obj.is_class
                        obj.full_name  = [obj.package_prefix '.' obj.class_name];
                    else
                        obj.full_name  = [obj.package_prefix '.' obj.class_name '.' obj.name];
                        
                    end
                else
                    obj.full_name  = [obj.package_prefix '.' obj.name];
                    if exist(obj.full_name,'class') == 8
                        obj.is_class = true;
                        obj.class_name = obj.name;
                    else
                        obj.is_function = true;
                    end
                end
            else % class without package
                % looking for the presence of @ symbol or not
                % @ would be second to last-- grab entries(end-1);
                % if not, check exist (see above)
                % must be a class or a function
                %     class has either
                %     1 @ symbol
                %     2 name should exist as class (see above)
                %
                %     example 1: try @sl.sl
                %     example 2: try @sl.initialize
                %     example 3: startup.m
                %
                
                
                pen_ult = entries{end-1};
                ult = entries{end};
                
                %TODO: This should be merged with above
                %Where we pass in a package prefix and build the name
                %conditionally ...
                if pen_ult(1) == '@' % class folder (or class method in class folder)
                    obj.class_name = pen_ult(2:end);
                    obj.is_class = strcmp(obj.name,obj.class_name);
                    obj.is_class_method = ~obj.is_class;
                    
                    if obj.is_class_method
                        obj.full_name  = [obj.class_name '.' obj.name];
                    else
                        obj.full_name = obj.class_name;
                    end
                    
                else % class or fcn not in folder
                    if exist(ult,'class') == 8
                        obj.is_class = true;
                        obj.class_name = obj.name;
                        obj.full_name = obj.class_name;
                    else % is function or something else
                        obj.is_function = true;
                        obj.full_name = obj.name;
                    end
                end
                
            end
        end
    end
    
end

