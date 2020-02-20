classdef theil_sen_result < sci.time_series.calculators.regression.result
    %
    %   Class:
    %   sci.time_series.calculators.regression.theil_sen_result
    %
    %   See Also
    %   --------
    %   sci.time_series.calculators.regression.theilSen
    
    properties
        training_data
        slope
        intercept
    end
    
    properties (Dependent)
        y_hat 
    end
    
    methods
        function value = get.y_hat(obj)
            value = obj.t_training*obj.slope + obj.intercept;
        end

    end
    

    
    methods
        function plot(obj)
            subplot(2,1,1)
            plot(obj.training_data)
            hold on
            plot(obj.t_training,obj.y_hat,'linewidth',2)
            hold off
            subplot(2,1,2)
            plot(obj.t_training,obj.residuals)
            ylabel(sprintf('Residuals (%s)',obj.training_data.units))
        end
    end
    
end

