classdef base < sl.obj.display_class
    %
    %   Class:
    %   sl.error.ml.base
    %
    %   Right now this class doesn't do anything, but it may one day!
    
    
    properties (Abstract)
        identifer %string
        
        is_dynamic %logical
        %true - the error message changes based on the situation
        %false - the error message is constant
        
        error_msg %string
        %For non-dynamic strings this is the error message. For dynamic
        %strings this can be empty.
        
        example_msgs %cellstr
        %For dynamic strings this should contain a representative list
        %of error messages.
    end
    
    methods
    end
    
end

