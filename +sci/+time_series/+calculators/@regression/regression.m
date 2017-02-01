classdef regression
    %
    %   Class:
    %   sci.time_series.calculators.regression
    
    properties
    end
    
    methods (Static)
        function result = linearFit(to_fit)
            [d t] = to_fit.getRawDataAndTime;    % d is the pressure, t is the time
            b = glmfit(t,d);
            result = sci.time_series.calculators.regression.linear_regression_result();
            result.coeffs = b;
            result.orig_data = to_fit;
        end
        result = theilSen(data);
    end
    
end

