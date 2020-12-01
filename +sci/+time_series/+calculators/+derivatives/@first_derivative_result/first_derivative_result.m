classdef first_derivative_result < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.derivatives.first_derivative_result
    %
    %   See Also
    %   --------
    %   sci.time_series.calculators.derivatives.first_derivative
    
    properties
        orig_data
        result_data
        filtered_original_data
    end
    
    methods
%         function obj = first_derivative_result()
%         end
    
        function plot(obj)
            yyaxis left
            plot(obj.orig_data)
            yyaxis right
            plot(obj.result_data)
            %TODO: This should really just restore ..., not default to left
            yyaxis left
        end
    end
    
end

