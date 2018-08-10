classdef result < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.regression.result
    %
    %   See Also
    %   ---------
    %   sci.time_series.calculators.regression
    %   sci.time_series.calculators.regression.theil_sen_result
    %   sci.time_series.calculators.regression.linear_regression_result
    
    properties (Abstract)
        training_data
    end
    
    properties (Dependent)
        residuals
        t_training
        y_training
    end
    
    methods
        function value = get.residuals(obj)
           value = obj.y_training - obj.y_hat;
        end
        function value = get.t_training(obj)
            [~,value] = obj.training_data.getRawDataAndTime();
        end
        function value = get.y_training(obj)
            value = obj.training_data.getRawDataAndTime();
        end
    end
end

