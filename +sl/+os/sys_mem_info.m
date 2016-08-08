classdef sys_mem_info
    %
    %   Class:
    %   sl.os.sys_mem_info
    %
    %   Requires sigar:
    %   http://sourceforge.net/projects/sigar/files/
    %   Should be initialized in sl.initialize
    %
    %   Old link:
    %   http://cpansearch.perl.org/src/DOUGM/hyperic-sigar-1.6.3-src/docs/javadoc/org/hyperic/sigar/Mem.html
    
    
    %TODO: Make total = used + free
    %TODO: Make gb variables
    
    properties
        %total
        used
        free
        actual_used
        actual_free
    end
    
    properties
       used_GB
       free_GB
    end
    
    methods
        function obj = sys_mem_info()
            %
            %   m = sl.os.sys_mem_info()
            %
            
           s = org.hyperic.sigar.Sigar;
           m = s.getMem;
           
           %obj.total = m.getRam;
           obj.used = m.getUsed;
           obj.free = m.getFree;
           obj.actual_used = m.getActualUsed;
           obj.actual_free = m.getActualFree;
           
        end
    end
    
end

