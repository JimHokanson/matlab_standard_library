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
    %
    %   sigar looks outdated
    %
    %   I wanted a nice way of assessing free memory that was cross
    %   platform. Sigar seemed useful but looks outdated. Not sure it
    %   works properly on modern systems.
    
    properties
        total
        used
        free
        used_percent
        free_percent
        actual_used
        actual_free
    end
    
    properties
        used_GB
        free_GB
        total_GB
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
            obj.used_percent = m.getUsedPercent;
            obj.free_percent = m.getFreePercent;
            %documentation?
            obj.actual_used = m.getActualUsed;
            obj.actual_free = m.getActualFree;
            %k,m,g
            obj.used_GB = obj.used/(1024^3);
            obj.free_GB = obj.free/(1024^3);
            obj.total_GB = obj.used_GB + obj.free_GB;
            
        end
    end
    
end

