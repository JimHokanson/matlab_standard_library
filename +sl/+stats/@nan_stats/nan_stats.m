classdef nan_stats < handle
    %
    %   Class:
    %   sl.stats.nan_stats
    
    %   TODO:
    %   Goal is to expose various status for either a cell array of vectors
    %   or a matrix without:
    %   1) Using the stats toolbox
    %   2) Needing to constantly reprocess values
    %   3) without memory changing - implement in C where possible
    
    properties (Dependent)
        mean
        std
        sem
    end
    
    properties (Hidden)
       %Log values once computed
       h__mean
       h__std
       h__sem
    end
    
    methods
        function obj = nan_stats()
            
        end
    end
    
end

