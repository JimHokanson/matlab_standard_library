classdef find_files_result < sl.obj.display_class
    %
    %   Class:
    %   sl.code.find_files_result
    %   
    
    properties
       d0 = '---- request info ----'
       containing %text to match
       root_folder_path
       use_regex = false
       d1 = '---- results ----'
       file_paths
       matching_I
       surrounding_text
    end
    
    properties (Dependent)
       regexp_containing_text 
    end
    
    methods
        function value = get.regexp_containing_text(obj)
           if obj.use_regex
              value = obj.containing;
           else
              value = regexptranslate('escape',obj.containing);
           end
        end
    end
    
    methods
        function obj = find_files_result(in,root_folder_path,file_paths,I,surrounding_text)
            obj.containing = in.containing;
            obj.root_folder_path = root_folder_path;
            obj.file_paths = file_paths;
            obj.matching_I = I;
            obj.surrounding_text = surrounding_text;
        end
        function replaceMatches(obj,new_text_value)
           [u_file_paths,uI] = sl.array.uniqueWithGroupIndices(obj.file_paths);
           regexp_pattern = obj.regexp_containing_text;
           
           for iFile = 1:length(u_file_paths)
               cur_file_path = u_file_paths{iFile};
               text = sl.io.fileRead(cur_file_path,'*char');
               
               %TODO: This could be optimized ...  
               text = regexprep(text,regexp_pattern,new_text_value);
               
               sl.io.fileWrite(cur_file_path,text);
           end
        end
    end
    
end

