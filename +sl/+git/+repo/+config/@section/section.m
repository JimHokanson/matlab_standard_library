classdef section
    %
    %   Class:
    %   sl.git.repo.config.section
    
    properties
       name
       subsection_names
    end
    
    methods
        function obj = section(h,name)
           %h %org.eclipse.jgit.storage.file.FileBasedConfig 
           
           obj.name = name;
           ss = h.getSubsections(name);
           obj.subsection_names = cell(ss.toArray());
        end
    end
    
end

