classdef find_local_peaks_result < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.event_calculators.find_local_peaks_result
    %
    %   See Also
    %   --------
    %   sci.time_series.calculators.event_calculators.findLocalPeaks
    
    properties
        source_data %sci.time_series.data or array
        indices  %[1 x n_peaks] Indices of peaks
        times    %Times of peak values
        values   %Values at the given peaks
        is_max   %whether peak is a max or min
    end
    
    methods
        function obj = find_local_peaks_result(source_data,indices,times,values,is_max)
            %
            %   obj =
            %   sci.time_series.calculators.event_calculators.find_local_peaks_result(...
            %       indices,times,values,is_max)
            obj.source_data = source_data;
            obj.indices = indices;
            obj.times = times;
            obj.values = values;
            obj.is_max = is_max;
        end
        function plot(obj)
            plot(obj.source_data)
            if isobject(obj.source_data)
                d = obj.source_data.d; 
                x = obj.times;
            else
                d = obj.source_data;
                x = obj.indices;
            end
            
            hold on
            plot(x,d(obj.indices),'o');
            hold off
        end
    end
end

