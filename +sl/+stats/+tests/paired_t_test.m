classdef paired_t_test < handle
    %
    %   Class:
    %   sl.stats.paired_t_test
    
    properties
        p
        ci
        stats
    end
    
    methods
        function obj = paired_t_test(x,y,varargin)
            %
            %   obj = sl.stats.paired_t_test(x,y)
            %
            %   Optional Inputs
            %   ---------------
            %   tail: (default 'both')
            %       'both' - mean is not zero
            %       'increase' - p => probability that 2nd input did not increase
            %       'decrease' - p => probability that 2nd input did not decrease
            
            in.tail = 'both';
            in = sl.in.processVarargin(in,varargin);
            
            switch lower(in.tail)
                case 'both'
                    tail = 'both';
                case 'increase'
                    tail = 'left';
                case 'decrease'
                    tail = 'right';
            end
            
            [~,obj.p,obj.ci,obj.stats] = ttest(x,y,'tail',tail);
        end
    end
    
end

