function results = simpleThreshold(data_objs,threshold_value,look_for_positive,varargin)
%
%
%   sci.time_series.event_calculators.simpleThreshold(data_obj,threshold_value,look_for_positive,varargin)
%
%   Calculates 
%   
%   Inputs:
%   -------
%
%   Optional Inputs:
%   ----------------
%
%   Outputs:
%   --------
%   results : simple_threshold_results

in.min_time    = [];
in.min_samples = [];
in.max_time    = [];
in.max_samples = [];
in.max_value   = []; %
in = sl.in.processVarargin(in,varargin);

%We might be able to borrow ideas from:
%https://github.com/JimHokanson/SegwormMatlabClasses/blob/master/%2Bseg_worm/%2Bevents/findEvent.m

if ~isempty(in.max_value)
    if look_for_positive
        %TODO: Check that in.max_value and look_for_positive applies
        mask_fh = @(x)(x >= threshold_value & x <= in.max_value);
    else
        mask_fh = @(x)(x <= threshold_value & x >= in.max_value);
    end
else
    if look_for_positive
        mask_fh = @(x)(x >= threshold_value);
    else
        mask_fh = @(x)(x <= threshold_value);
    end
end

results_ca = cell(1,length(data_objs));

for iObj = 1:length(data_objs)
    cur_data_obj = data_objs(iObj);
    mask = mask_fh(cur_data_obj.d);
    
    bti = sl.array.bool_transition_info(mask,'time',cur_data_obj.time);
    
    mask2 = true(1,bti.n_true);
    
    if ~isempty(in.min_time)
        mask2(bti.true_durations < in.min_time) = false;
    end
    if ~isempty(in.min_samples)
        mask2(bti.true_sample_durations < in.min_samples) = false;
    end
    if ~isempty(in.max_time)
        mask2(bti.true_durations > in.max_time) = false;
    end
    if ~isempty(in.max_samples)
        mask2(bti.true_sample_durations > in.max_samples) = false;
    end
    
    temp = sci.time_series.event_results.simple_threshold_results;
    
    temp.threshold_start_times = bti.true_start_times(mask2);
    temp.threshold_start_I     = bti.true_start_indices(mask2);
    temp.threshold_end_times   = bti.true_end_times(mask2);
    temp.threshold_end_I       = bti.true_end_indices(mask2);
    
    results_ca{iObj} = temp;
end

results = [results_ca{:}];

end