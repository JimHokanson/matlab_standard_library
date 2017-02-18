classdef n_samples_blanking_approach1
    %
    %   Class
    %   sci.time_series.filter.results.artifact_removal.n_samples_blanking_approach1
    
    properties
        %TODO: Get a dt
        average_stimulus_response
        corr_width_used
        average_correlation
        n_samples_to_blank
    end
    
    methods
        function plot(obj)
            %t = 1:lengh(obj.average_stimulus_response);
            yyaxis left
            plot(obj.average_stimulus_response)
            ylabel('Average Stimulus Response')
            
            yyaxis right
            plot(obj.average_correlation)
            ylabel('Average correlation starting at given sample')
        end
    end
    
end

