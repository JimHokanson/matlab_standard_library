classdef persistant_value < handle
    %
    %   Class:
    %   sl.obj.persistant_value
    %
    %   Basically this class has a property that can be used
    %   to maintain state across function calls. Unlike peristent 
    %   values in functions, this can be tied to the holder of the object.
    %   This allows a single function to work with multiple persisent
    %   values.
    %
    %   This was written for plotting callbacks which want to track the 
    %   last ylim or xlim values that are handled by the function.
    %
    %   See Also
    %   --------
    %   sl.plot.type.verticalLines
    
    properties
        value %main value to use
        aux_value %auxillary value to take with main value
    end
    
    methods
    end
end

