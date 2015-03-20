classdef looped_options < handle
    %
    %   Class:
    %   sl.in.looped_options
    
    properties
       orig_options;
    end
    
    methods
        function obj = looped_options(orig_options,potential_loop_option_names)
           obj.orig_options = orig_options;
        end
        function getNextOptions(obj)
           %Replace all original options that vary with their singular loop values... 
        end
    end
    
end

