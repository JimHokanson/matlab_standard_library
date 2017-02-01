classdef theil_sen_result
    %
    %   Class:
    %   sci.time_series.calculators.regression.theil_sen_result
    
    properties
        training_data
        slope
        intercept
    end
    
    properties (Dependent)
        y_hat 
        residuals
    end
    
    methods
        function value = get.y_hat(obj)
            value = obj.t_training*obj.slope + obj.intercept;
        end
        function value = get.residuals(obj)
           value = obj.y_training - obj.y_hat;
        end
    end
    
    properties (Dependent)
        t_training
        y_training
    end
    
    methods
        function value = get.t_training(obj)
            [~,value] = obj.training_data.getRawDataAndTime();
        end
        function value = get.y_training(obj)
            value = obj.training_data.getRawDataAndTime();
        end
    end
    
    methods
        function plot(obj)
            subplot(2,1,1)
            plot(obj.training_data)
            hold all
            plot(obj.t_training,obj.y_hat,'linewidth',2)
            subplot(2,1,2)
            plot(obj.t_training,obj.residuals)
        end
    end
    
end

