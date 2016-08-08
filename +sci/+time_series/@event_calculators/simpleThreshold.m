function results = simpleThreshold(data_objs,threshold_value,look_for_positive,varargin)
%x Thresholds a time series and groups consecutive true values as events
%
%   sci.time_series.event_calculators.simpleThreshold(data_obj,threshold_value,look_for_positive,varargin)
%
%   
%   Inputs:
%   -------
%   data_objs :
%   threshold_value :
%   look_for_positive :
%
%   Optional Inputs: (Note, the majority of these are not used by default)
%   ----------------
%   min_intertime : 
%       Nullifies an event if it occurs too soon
%   min_time :
%       Nullifies an event if it is too short
%   min_samples :
%       Nullifies an event if it has too few samples
%   max_time :
%       Nullifies an event if it is too long
%   max_samples :
%       Nullifies an event if it has too many samples
%   max_value : 
%       A data point is not considered logically true, and thus elligible to
%       be grouped into an event, if it exceeds this value. The default
%       behavior is to allow any data value that exceeds a threshold. This
%       essentially allows a between comparison, rather than just an 
%       exceeds/threshold comparision.
%   join_time : 
%       Intertimes that are less than this value allow are combined.
%
%
%   TODO: We could allow a custom data to logical function
%
%   Outputs:
%   --------
%   results : sci.time_series.event_results.simple_threshold_results
%       One object for every input data object is returned.
%
%   See Also:
%   sl.array.bool_transition_info

in.mask_fh = [];
in.min_intertime = [];
in.min_time    = []; 
in.min_samples = [];
in.max_time    = []; %If longer than this, reject ...
in.max_samples = [];
in.max_value   = []; %
in.join_time   = [];
in = sl.in.processVarargin(in,varargin);

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
    mask = mask_fh(cur_data_obj.d);
    
    bti = sl.array.bool_transition_info(mask,'time',cur_data_obj.time);
    
    %This might not be the most efficient, but it works ...
    if ~isempty(in.join_time)
        if any(bti.false_durations < in.join_time)
            bti.negateSections(bti.false_durations < in.join_time,false)
            
            if any(bti.false_durations < in.join_time)
                fprintf(2,'Need to finish this code, enetering keyboard mode now\n');
                keyboard
            end
            %We'll shoot for 1 drop, multiple drops will need to be handled
            %later on ...
            
            
            
%             start_times = bti.true_start_times;
%             current_start = start_times(1);
%             delete_mask = false(1,length(start_times));
%             for iStart = 2:length(start_times);
%                 if 
%             fprintf(2,'Need to finish this code\n');
%             keyboard
            %I think the best approach to handling this is to make a method
            %in bti which supports merging with previous entries
            %
            %Then we would likely need to use some Matlab hack to
            %accomplish the merging efficienctly
        end
        %The idea was to modify the mask and pass it back into the
        %bool_transition_info function
    end
    
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
    
    temp = sci.time_series.event_results.simple_threshold_results;
    
    temp.threshold_start_times = bti.true_start_times(mask2);
    temp.threshold_start_I     = bti.true_start_indices(mask2);
    temp.threshold_end_times   = bti.true_end_times(mask2);
    temp.threshold_end_I       = bti.true_end_indices(mask2);
    temp.n_samples = length(mask);
    
    
    
    results_ca{iObj} = temp;
end

results = [results_ca{:}];

end