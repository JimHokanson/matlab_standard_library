classdef linear_regression_result < sci.time_series.calculators.regression.result
    %
    %   Class: 
    %   sci.time_series.calculators.regression.linear_regression_result
    %
    %   See Also
    %   --------
    %   sci.time_series.calculators.regression
    
    properties
        training_data
        coeffs
        slope
        intercept
    end
    
    properties (Dependent)
        y_hat
    end
    
    % ------ Dependent Methods -----------------------------------------
    methods 
        function value = get.y_hat(obj)
            [~, t] = obj.training_data.getRawDataAndTime();
            value = obj.intercept+obj.slope.*t;
        end 
    end
    % ---------- Methods ---------------
    methods 
        function plot(obj)
%             figure(1)
%             clf
            plot(obj.training_data)
            hold on
            [~, time] = obj.training_data.getRawDataAndTime();
            plot(time, obj.y_hat, 'LineWidth', 4)
            
        end
    end
    
end

