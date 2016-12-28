classdef subset_options
    %
    %   Class:
    %   sci.time_series.subset_options
    %
    %   I'm using this as a container for static methods, not as a class.
    %
    %   It might be good to merge with:
    %   sci.time_series.subset_options.main_subset_option
    
    %Layout:
    %---------------------------------------------------------------------
    %  These functions are supposed to build objects. These objects
    %  then do the processing
    %
    %   At this time I've only created:
    %   sci.time_series.subset_options.epoch
    %
    %   need discrete_event and times_or_samples (not sure of name)
    
    properties
    end
    
    methods (Static)
        function options = fromEpoch(name,varargin)
            in.indices = 1;
            in = sl.in.processVarargin(in,varargin);
            options = sci.time_series.subset_options.epoch;
            options.indices = in.indices;
            options.epoch_name = name;
        end
        function options = fromEpochAndPct(name,percent,varargin)
            %
            %   options = sci.time_series.subset_options.fromEpochAndPct(name,percent,varargin)
            %
            %   Inputs
            %   ------
            %   name: string
            %       Name of the epoch to use ...
            %   percent: [start stop]
            %       Values are typically between 0 and 1
            %
            %   Example
            %   -------
            %   options = sci.time_series.subset_options.fromEpochAndPct('fill_to_first_bc',[0.2 0.8])
            in.indices = 1;
            in = sl.in.processVarargin(in,varargin);
            options = sci.time_series.subset_options.epoch;
            options.indices = in.indices;
            options.epoch_name = name;
            options.percent = percent;
        end
    end
    
end

