classdef (Hidden) sl_data_singleton < sl.obj.handle_light
    %
    %   Class:
    %       sl.obj.sl_data_singleton
    %
    %   This class should handle code related to 
    
    properties
       base_path
    end
    
    methods (Static)
        function getClassSavePath(obj)
            
        end
    end
    
    methods (Abstract,Static)
        obj = getInstance()
    end

%     methods (Static)
%         function output = getInstance()
%            persistent local_obj
%            if isempty(local_obj)
%                local_obj = sl.editor.interface;
%            end
%            output = local_obj;
%         end
%     end
    
    
end

