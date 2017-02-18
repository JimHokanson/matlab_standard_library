classdef time_sample_processor < sci.time_series.subset_retrieval.processor
    %
    %   Class
    %   sci.time_series.subset_retrieval.time_sample_processor
    
    %This class is not yet finished ...
    
    properties
        d0 = '---------  Must have values -----------'
        un = true;
        align_time_to_start = false;
        
        d1 = '---------  One of these must have values ---------'
        start_samples
        start_times
        
        
        %These are optional
        stop_name
        stop_indices = 1;
        time_duration
        sample_duration
        time_offsets
        sample_offsets
        
        
    end
    
    methods
    end
    
end

