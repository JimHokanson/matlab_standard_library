classdef linear_regression_result
    %
    %   Class: 
    %   sci.time_series.calculators.regression.linear_regression_result
    %
    
    properties
        coeffs % coeffs(2) is the slope (compliance), coeffs(1) is the intercept
        orig_data       
    end
    
    properties (Dependent)
    y_hat
    orig_time
    end
    
    % ------ Dependent Methods -----------------------------------------
    methods 
        function value = get.y_hat(obj)
            [d, t] = obj.orig_data.getRawDataAndTime();
            value = obj.coeffs(1)+obj.coeffs(2).*t;
        end 
        function value = get.orig_time(obj)
            [d, t] = obj.orig_data.getRawDataAndTime();
            value = t;
        end
    end
    % ---------- Methods ---------------
    methods 
        function plot(obj)
            figure(1)
            clf
            plot(obj.orig_data)
            hold on
            y_hat = obj.y_hat;
            time = obj.orig_time;
            plot(time, y_hat, 'LineWidth', 4)
            
            % ylabel('pressure'+ obj.orig_data.units)
        end
    end
    
end

