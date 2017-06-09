classdef local_max_result < handle
    %   sci.time_series.calculators.event_calculators.local_max_result
    %   stores the result of:
    %   sci.time_series.calculators.event_calculators.findLocalMaxima
    
    properties
        pks
        locs
        time_locs
    end
    
    methods
        function obj = local_max_result(pks, locs, varargin)
           obj.pks = pks;
           obj.locs = locs;
           if nargin == 3
              obj.time_locs = varargin{1}; 
           end   
        end
    end
    
end

