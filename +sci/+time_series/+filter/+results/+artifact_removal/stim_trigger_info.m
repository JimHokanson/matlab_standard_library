classdef stim_trigger_info
    %
    %   Class
    %   sci.time_series.filter.results.artifact_removal.stim_trigger_info
    %
    %   See Also
    %   sci.time_series.filter.results.artifact_removal_result
    %
    %   This class aligns the stimulus trigger times and extracts
    %   a standard trigger signal. This can then be used to blank
    %   an artifact for the appropriaet duration.
    
    properties
        raw_data
        avg_trigger
        window_back_time
        window_forward_time
        window_duration
    end
    
    methods
        function obj = stim_trigger_info(trig_chan,start_times)

           FRACTION_SAMPLES_USE = 0.4;  %How many samples to use
           %when looking at the trigger. In reality this could probably
           %be a really low number.
           
           N_SAMPLES_BACK = 5;
           N_SAMPLES_OK_TO_DROP = 1;
           
           obj.raw_data = copy(trig_chan);
                      
           trigger_start_I = trig_chan.ftime.getNearestIndices(start_times);

           min_sample_diff = min(diff(trigger_start_I));
           
           %TODO: This is arbitrary and might need to change ...
           stim_aligned = sl.matrix.from.startAndLength(trig_chan.d,trigger_start_I-N_SAMPLES_BACK,round(FRACTION_SAMPLES_USE*min_sample_diff),'by_row',false);
           avg_stim = mean(stim_aligned,2);
           obj.avg_trigger = avg_stim;
           
           
           abs_avg_stim = abs(avg_stim);
           max_stim = max(abs_avg_stim);
           I = find(abs_avg_stim > 0.1*max_stim);
           
           n_samples_found = length(I);
           n_samples_spanned = I(end)-I(1)+1;
           if n_samples_spanned > n_samples_found + N_SAMPLES_OK_TO_DROP
              error('Unhandled case') %Jim needs to look at this case ...
           end
           
           sample1 = trigger_start_I(1) + I(1) - N_SAMPLES_BACK - 1;
           sample2 = trigger_start_I(1) + I(end) - N_SAMPLES_BACK - 1;
           
           dt1 = trig_chan.ftime.getTimesFromIndices(sample1) - start_times(1);
           dt2 = trig_chan.ftime.getTimesFromIndices(sample2) - start_times(1);

           obj.window_back_time = dt1;
           obj.window_forward_time = dt2;
           obj.window_duration = dt2 - dt1; 
        end
    end
    
end

