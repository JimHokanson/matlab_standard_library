classdef file_path_info
    %
    %   Class:
    %   sl.obj.file_path_info
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
       package_prefix
       name %class_name or function name
       class_name %only class name if found
       full_name %name with package_prefix attached
    end
    
    methods
        function obj = file_path_info(file_path)
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
           is_package = cellfun(@(x) x(1) == '+',entries);
           
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
                 obj.is_class   = true;
                 obj.class_name = next_name(2:end);
                 obj.name = obj.class_name;
                 obj.full_name  = [obj.package_prefix '.' obj.class_name];
              else
                 obj.name = next_name;
                 obj.full_name  = [obj.package_prefix '.' obj.name]; 
                 if exist(obj.full_name,'class') == 8
                    obj.is_class = true;
                    obj.class_name = obj.name;
                 end
              end

           else
               error('Code not yet written, sorry :/')
           end
        end
    end
    
end

