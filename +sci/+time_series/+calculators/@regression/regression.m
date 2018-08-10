classdef regression < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.regression
    
    properties
    end
    
    methods (Static)
        function result = linear(data)
            %
            %   sci.time_series.calculators.regression.linear(to_fit)
            %
            %   TODO: Expose options for regression
            %
            %   
            
            
            [d,t] = data.getRawDataAndTime;    % d is the pressure, t is the time
            if size(d,2) > 1
                error('Unhandled case')
            end
            b = glmfit(t,d);
            
            %Result population
            %---------------------------------------
            result = sci.time_series.calculators.regression.linear_regression_result();
            result.slope = b(2);
            result.intercept = b(1);
            result.training_data = data;
        end
%         function result = minFit(data,
        result = theilSen(data);
    end
    
end

