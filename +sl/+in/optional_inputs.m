classdef (Hidden) optional_inputs < dynamicprops
    %
    %   Class:
    %   sl.in.optional_inputs
    %
    %   NOT YET IMPLEMENTED
    %
    %   sl.in.processVarargin()
    %
    %   TODO: I'm not sure how I want to use this yet ...
    %
    %   I wanted to build something that was more ammenable to deeply
    %   nested function calls all with optional inputs ...
    
    properties
       p__usedProperties 
    end
    
    methods
        function obj = optional_inputs(in_struct)
            fn = fieldnames(in_struct);
            for iProp = 1:length(fn)
                cur_name = fn{iProp};
                addprop(obj,cur_name);
                obj.(cur_name) = in_struct.(cur_name);
            end
        end
    end
    
end

