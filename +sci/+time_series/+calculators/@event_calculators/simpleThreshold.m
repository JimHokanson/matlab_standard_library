function results = simpleThreshold(data_objs,threshold_value,look_for_positive,varargin)
%x Thresholds a time series and groups consecutive true values as events
%
%   results = sci.time_series.calculators.event_calculators.simpleThreshold(...
%               data_obj,threshold_value,look_for_positive,varargin)
%
%   results = sci.time_series.calculators.event_calculators.simpleThreshold(...
%               threshold_result,1,epoch_value,varargin)
%
%   In the 2nd case, we use the epochs to generate a mask. This class
%   then serves to further refine the epochs. This is useful as sometimes
%   the order of operations can be difficult to infer.
%
%
%   Inputs
%   ------
%   data_objs : sci.time_series.data
%   threshold_value :
%   look_for_positive : logical
%       - true, values should be above the threshold
%       - false, values should be below the threshold
%   threshold_result : sci.time_series.event_results.simple_threshold_results
%   epoch_value : logical
%       If true, the epochs generate a positive mask. Otherwise, the
%       non-epoch spans are true, and the epochs are false. In other words,
%       this is a way of setting all non-epochs to epochs and epochs to
%       nothing.
%           
%                           epoch         epoch
%                        ---|||||---------||||||-----
%
%                           epoch         epoch
%          true          ---|||||---------||||||-----
%
%                        epoch   epoch          epoch
%          false         |||-----|||||||||------|||||
%
%
%   Optional Inputs
%   ---------------
%   mask_fh : function handle (default, not used)
%       Given an input array of values, the function handle should return
%       a mask of true/false values. This can be used to make a custom
%       filter on the input data in turning it into a mask.
%
%       e.g. 'mask_fh',@(x) ( (x > 0.5 & x < 1) | (x >= 2 & x <= 3))
%
%           This means the input value is true when between 0.5 and 1
%           or between (or equal to) 2 and 3.
%   allow_starting_true : (default true)
%       Whether an epoch can start with the first sample. If false
%       the first sets of trues that would normally define an epoch
%       are dropped.
%   allow_ending_true: (default true)
%       Similar to 'allow_starting_true' but for the end.
%
%   allow_border_trues: (default true)
%       if set overrides allow_starting_true and allow_ending_true
%
%   original_data : 
%       This can pass an 'original dataset' to the results for later
%       plotting in cases when the input data has been processed
%   min_intertime :  (default, not used)
%       Nullifies an event if it occurs too soon.
%   min_time : (default, not used)
%       Nullifies an event if it is too short.
%   min_samples : (default, not used)
%       Nullifies an event if it has too few samples.
%   max_time : (default, not used)
%       Nullifies an event if it is too long.
%   max_samples : (default, not used)
%       Nullifies an event if it has too many samples.
%   max_value : (default, not used)
%       A data point is not considered logically true, and thus elligible to
%       be grouped into an event, if it exceeds this value. The default
%       behavior is to allow any data value that exceeds a threshold. This
%       essentially allows a between comparison, rather than just an
%       exceeds/threshold comparision.
%
%   Below options get implemented before and after the other filters. If a
%   different order is needed you can run the results, and then call the
%   function again:
%       result = simpleThreshold(result,1,epoch_value)
%
%   join_time : (default, not used)
%       Intertimes that are less than this value allow are combined. This
%       is done before the other filters ...
%   join_after_time : (default, not used)
%       Same as 'join_time', but this is run after the other filters (i.e.
%       after min max filters)
%
%   Outputs
%   -------
%   results : sci.time_series.event_results.simple_threshold_results
%       One object for every input data object is returned.
%
%
%   Examples
%   --------
%   d = sci.time_series.data.example(2);
%   d = abs(d);
%   c = d.calculators;
%   result = c.eventz.simpleThreshold(d,2,true);
%   plot(result)
%   
%
%
%   Improvements
%   -----------------------------------------------------------------------
%   1) Allow a set of filters such as:
%   'filters',{'min_time' 3 'join_time' 2 'max_time',5}
%   This would then create epochs based on the min_time and then
%   run the output against join_time
%   2) Provide a filter based on energy (either averages, i.e. normalized
%   to time or just the absolute value, not-normalized to time)
%
%   See Also
%   --------
%   sl.array.bool_transition_info

in.original_data = [];
in.mask_fh = [];
in.allow_starting_true = true;
in.allow_ending_true = true;
in.allow_border_trues = [];
in.min_intertime = [];
in.min_time    = [];
in.min_samples = [];
in.max_time    = []; %If longer than this, reject ...
in.max_samples = [];
in.max_value   = []; %
in.join_time   = [];
in.join_after_time = [];
in = sl.in.processVarargin(in,varargin);

%We drop in.allow_border_trues in favor of 
%the individual cases. Note that we've set it to empty so that it not being
%empty indicates a user specification
if ~isempty(in.allow_border_trues)
    in.allow_starting_true = in.allow_border_trues;
    in.allow_ending_true = in.allow_border_trues;
end

%We might be able to borrow ideas from:
%https://github.com/JimHokanson/SegwormMatlabClasses/blob/master/%2Bseg_worm/%2Bevents/findEvent.m

if isempty(in.mask_fh)
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
else
    mask_fh = in.mask_fh;
end

results_ca = cell(1,length(data_objs));

for iObj = 1:length(data_objs)
    cur_data_obj = data_objs(iObj);
    
    if isa(cur_data_obj,'sci.time_series.data')
        mask = mask_fh(cur_data_obj.d);
        time = cur_data_obj.time;
        
    else
        %cur_data_obj: sci.time_series.event_results.simple_threshold_results
        epoch_value = look_for_positive;
        mask = cur_data_obj.getMask(epoch_value);
        time = cur_data_obj.data.time;
        if isempty(in.original_data)
            in.original_data = cur_data_obj.original_data;
        end
        cur_data_obj = cur_data_obj.data;
    end
    
    %getMask
    
    bti = sl.array.bool_transition_info(mask,'time',time);
    
    %This might not be the most efficient, but it works ...
    if ~isempty(in.join_time)
        if any(bti.false_durations < in.join_time)
            bti.negateSections(bti.false_durations < in.join_time,false)
            if any(bti.false_durations < in.join_time)
                %I'm not sure how this would ever be true ...
                fprintf(2,'Need to finish this code, enetering keyboard mode now\n');
                keyboard
            end
        end
    end
    
    %This mask indicates which true epochs we are going to keep
    mask2 = true(1,bti.n_true);
    
    if ~in.allow_starting_true && bti.true_start_indices(1) == 1
        mask2(1) = false;
    end
    if ~in.allow_ending_true && bti.true_end_indices(end) == length(mask)
       mask2(end) = false; 
    end
    
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
    
    if ~isempty(in.min_intertime)
        %TODO: We could maybe improve the speed by doing a search over
        %valid Is first find(mask2)
        %
        %for iTime = only_valid_values_I ....
        
        st = bti.true_start_times;
        et = bti.true_end_times;
        
        min_intertime = in.min_intertime;
        
        last_valid_I = find(mask2,1);
        for iTime = last_valid_I+1:length(mask2)
            
            if ~mask2(iTime)
                continue
            end
            
            if st(iTime) - et(last_valid_I) > min_intertime
                last_valid_I = iTime;
            else
                mask2(iTime) = false;
            end
        end
    end
    
    if ~isempty(in.join_after_time)
        %TODO: I'm not sure if I can ask bti to do this ...
        %Creating a mask from only certain true or false indices
        mask3 = false(1,length(mask));
        start_I = bti.true_start_indices(mask2);
        end_I = bti.true_end_indices(mask2);
        for i = 1:length(start_I)
            mask3(start_I(i):end_I(i)) = true;
        end
        bti = sl.array.bool_transition_info(mask3,'time',cur_data_obj.time);
        if any(bti.false_durations < in.join_after_time)
            bti.negateSections(bti.false_durations < in.join_after_time,false)
        end
        mask2 = true(1,bti.n_true);
    end
    
    temp = sci.time_series.event_results.simple_threshold_results;
    
    temp.data = copy(cur_data_obj);
    if isempty(in.original_data)
        temp.original_data = temp.data;
    else
        temp.original_data = in.original_data;
    end
    
    temp.bti = bti;
    temp.start_time = bti.start_time;
    temp.threshold_start_times = bti.true_start_times(mask2);
    temp.threshold_start_I     = bti.true_start_indices(mask2);
    temp.threshold_end_times   = bti.true_end_times(mask2);
    temp.threshold_end_I       = bti.true_end_indices(mask2);
    temp.n_samples = length(mask);
    
    results_ca{iObj} = temp;
end

results = [results_ca{:}];

end