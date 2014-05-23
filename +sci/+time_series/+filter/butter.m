classdef butter < handle
    %
    %   Class:
    %   sci.time_series.filter.butter
    %   
    %   TODO: dt should not be a property of this but of the filterer
    
    properties
       order   %Filter order
       cutoff 
       
    end
    
    methods
        function obj = butter()
            
        end
    end
    
    methods (Static)
        function obj = createLowPassFilter(order,cutoff,dt)
            
        end
    end
    
end

