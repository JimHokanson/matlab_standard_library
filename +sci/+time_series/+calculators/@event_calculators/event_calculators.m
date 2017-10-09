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
        
        
        
        result = findLocalPeak(data, search_type, varargin)
        %TODO: Get this from OW code
        
        function obj =  findPeaks(data,type,varargin)
            %
            %   This function is a wrapper to Matlab's findPeaks() function.
            %   We might remove it if we can provide better functionality
            %   in the other functions.
            %
            %   TODO: the output of this function is hard to deal with/not at
            %   all efficient
            %   inputs:
            %   -data: sci.time_series.data class
            %   -varargin: name-value pairs for findpeaks (see matlab documentation)
            %   -type:
            %       1: just maximums
            %       2: just minimums
            %       3: both maximums and minimums
            %
            %   outputs:
            %   -obj: sci.time_series.calculators.event_calculators.find_peaks_result
            
            %   examples:
            %{
             findPeaks(data,3,'MinPeakHeight',threshold)
            %}
            obj = sci.time_series.calculators.event_calculators.find_peaks_result(data,type,varargin{:});
        end
    end
end


