classdef memory_info
    %
    %   Class:
    %   sl.ml.memory_info
    %
    %   http://stackoverflow.com/questions/4762044/matlab-memory-function-on-mac
    %
    %   Goal:
    %   Encapsulate the memory() command and provide mac support
    
    properties
       %These values from memory() are limited by the swap-file which I'd
       %like to ignore
       largest_array_possible
       available_memory
       
       memory_used_by_matlab
       physical_ram
       
       java_total_memory
       java_free_memory
       java_max_memory %What does this even mean?
    end
    
    methods
        function obj = memory_info()
            
            obj.java_total_memory = java.lang.Runtime.getRuntime.totalMemory;
            obj.java_free_memory = java.lang.Runtime.getRuntime.freeMemory;
            obj.java_max_memory = java.lang.Runtime.getRuntime.maxMemory;
            
            
        end
    end
    
end

