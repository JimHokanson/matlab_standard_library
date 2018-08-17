classdef find_local_peaks_result < handle
    %
    %   Class:
    %   sci.time_series.calculators.event_calculators.find_local_peaks_result
    %
    %   See Also
    %   --------
    %   sci.time_series.calculators.event_calculators.findLocalPeaks
    
    properties
        indices  %[1 x n_peaks] Indices of peaks
        times    %Times of peak values
        values   %Values at the given peaks
        is_max   %whether peak is a max or min
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

