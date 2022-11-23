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
        function plot(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   data_options : cell of name/value pairs
            %       This gets passed to the plot of the original data
            %   line_options : cell of name/value pairs
            %       This gets passed to the fitted line
            
            in.data_options = {};
            in.line_options = {};
            in = sl.in.processVarargin(in,varargin);
            plot(obj.training_data,in.data_options{:})
            hold on
            [~, time] = obj.training_data.getRawDataAndTime();
            plot(time, obj.y_hat, 'LineWidth', 4,in.line_options{:})
            %TODO: Restore plot option
        end
    end
    
end

