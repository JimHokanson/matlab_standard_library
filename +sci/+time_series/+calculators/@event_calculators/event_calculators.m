classdef event_calculators < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.event_calculators
    
    properties
    end
    
    methods (Static)
        
        
        %sci.time_series.calculators.event_calculators.simpleThreshold
        result_obj = simpleThreshold(data_obj,threshold_value,look_for_positive,varargin)
        %
        %   This function returns epochs detailing all runs of true and
        %   false based on thresholding the data, as well as other rules
        %
        %   T T T F F F F T T F F F F 
        %   ----- ------- --- -------  <= epochs
        %
        
        
        
        result = findLocalPeaks(data, search_type, varargin)
    end
end


