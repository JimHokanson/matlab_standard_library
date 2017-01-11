classdef nan_stats
    %
    %   Class:
    %   sl.stats.nan_stats
    
    methods (Static)
        function value = sem(data,dim)
            %
            %   value = sl.stats.nan_stats.sem(data,dim);
            %
            if nargin < 2
               dim = sl.array.firstNonSingletonDimension(data);
            end
            n_values = sum(~isnan(data),dim);
            value = std(data,0,dim,'omitnan')./sqrt(n_values);
        end
    end
    
end

