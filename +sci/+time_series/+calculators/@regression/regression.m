classdef regression
    %   
    %   Class: 
    %   sci.time_series.calculators.regression
    
    properties
    end
    
    methods (Static)
        function result = linearFit(to_fit)
   
            time_dat=linspace(to_fit.time.start_time,to_fit.time.end_time,to_fit.time.n_samples)
            pressure_dat=to_fit.d;
            
            b=glmfit(time_dat,pressure_dat);
            
            result = sci.time_series.calculators.regression.linear_regression_result();
           
            result.coeff = b;
            %result.x_orig = 
            %result.y_orig = 
            
        end
    end
       
end

