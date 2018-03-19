classdef find_local_peaks_result < handle
    %
    %   Class:
    %   sci.time_series.calculators.event_calculators.find_local_peaks_result
    
    properties
        indices
        times
        values
        is_max
    end
    
    methods
        function obj = find_local_peaks_result(indices,times,values,is_max)
            %
            %   obj =
            %   sci.time_series.calculators.event_calculators.find_local_peaks_result(...
            %       indices,times,values,is_max)
            obj.indices = indices;
            obj.times = times;
            obj.values = values;
            obj.is_max = is_max;
        end
    end
end

