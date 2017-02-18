classdef artifact_removal_result %< sl.obj.dict
    %
    %   Class
    %   sci.time_series.filter.results.artifact_removal_result
    

    properties
        triggered_responses
    	avg_response
        original_data
        filtered_data
        blanking_used
        start_indices
        n_samples_blanking_result %Type varies depending on the approach used
        %Although currently only 1 approach is implemented
        %   sci.time_series.filter.results.artifact_removal.n_samples_blanking_approach1
    end

    
    methods
        %function getBlankingMask()
        %   blanking_used
        %   start_indices
        %   n_samples_blanking_result
        %end
        function plot(obj)
           subplot(2,1,1)
           plot(obj.original_data)
           hold on
           plot(obj.filtered_data)
           subplot(2,1,2)
           plot(obj.avg_response)
        end
    end
    
end

