classdef path
    %
    %   Class:
    %   sl.path
    
    properties
    end
    
    methods (Static,Hidden)
        function subs_mask = matchSubdirectories(path_entries,base_path)
            %matchSubdirectories 
            %
            %   subs_mask = sl.path.matchSubdirectories(path_entries,base_path)
            %
            %   IMPROVEMENTS
            %   ===========================================================
            %   1) Allow multiple base paths
            %   2) 
            
            %in.include_base_path
            %in = sl.in.processVarargin(in,varargin);
            
            %This is critical to match only subdirectories ...
            if base_path(end) ~= filesep
                base_path = [base_path filesep]; 
            end
            
            subs_mask = strncmp(base_path,path_entries,length(base_path)); 
            
            %{
            @TEST_CODE
            
                path_entries = 
                subs_mask    = sl.path.matchSubdirectories(path_entries,base_path)
            
            
            %}
        end
    end
    
    methods (Static)
        
    end
    
end

