classdef correlation < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.correlation
    
    properties
    end
    
    methods
%         function obj = correlation()
%         end
    end
    methods (Static)
        function result = localCrossCorrelation(obj1,obj2,varargin)
            %TODO: The goal is to compute multiple cross-correlations
            %of subsets of the data ...
            
            %Parameters
            %----------
            %1) What local time range to test, this should be of #2 with respect
            %to #1, e.g. something like [-10 1] which means tests #2
            %shifted by -10 seconds to 1 second forward for each cross
            %correlation ...
            %2) What width of data to test at a given time
            %3) Optional: allowed range of max shift ...
            %4) Optional: behavior when max not in range 
            %   => 1) use max of value within range
            %   => 2) keep default value
            %5) Optional: default value => NaN,0,???
            %6) What global time range to test
            %7) Optional: dt for evaluating the lcc
            
            
        end
    end
end

