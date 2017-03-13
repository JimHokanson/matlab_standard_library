classdef stim_artifact_remover < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.filter.stim_artifact_remover
    %
    %   See Also
    %   --------
    %   sci.time_series.event_calculators.simpleThreshold
    %
    %   Usage
    %   --------
    %   1) Create the constructor and populate options
    %
    %   2) Call the filter method
    %   The constructor should just take options.
    
    %{
    TODO:
        For expt_id = '161010_E', trial # 8, the defaults fail
        because we evoke a response.
        We should really look for a response during the stimulus
        that falls back to 0 or that has some decay ...
    
    %}
    
    
    %Processing Options
    %----------------------------------------------------------------------
    properties
        d0 = '---------  Blanking Options  -----------'
        blank_artifact = true
        
        blanking_type = 3
        %1) set to 0
        %2) set to NaN
        %3) linear interpolation - NYI
        
        n_samples_blank = -1
        %If specified, this is the # of samples that will be removed
        
        n_samples_blank_algorithm = 2
        %1) - Looks for a decrease in the correlation of sliding
        %windows that start at different locations.
        %2) - An improvement upon 1, whereby we look at the magnitude
        %of the stimulation artifact, and only remove the artifact
        %if it is relatively small
        
        
        nsb_n_samples_corr = 15
        
        %I was thinking of trying to fit a stimulus artifact shape
        %to the stimulus artifact ...
        %    x
        %   x x
        %  x   x    x x x x x x x x x x
        % x     x  x
        %x       x
        max_stimulus_phases = 'NYI' %
        
        d2 = '-------- Other Options -------------'
        max_artifact_duration = 0.01 %10 ms
    end
    
    methods
        function [filtered_data,info] = filter(obj,data,start_times,varargin)
            %
            %
            %
            %   Optional Inputs
            %   ---------------
            %   
            %
            %   Assumptions
            %   -----------
            %   1. The artifact starts at the given sample and goes forward
            %   in time. We could eventually do a check on this ...
            %   2. Artifacts don't overlap.
            %
            %   Improvements
            %   ------------
            %   1) Look for amplifier saturation
            %   2) Allow going backward in time
                        
            in.trigger_chan = [];
            in = sl.in.processVarargin(in,varargin);
            
            result = sci.time_series.filter.results.artifact_removal_result();

            if ~isempty(in.trigger_chan)
                trig_info = sci.time_series.filter.results.artifact_removal.stim_trigger_info(in.trigger_chan,start_times);
                back_time = trig_info.window_back_time;
                result.stim_trigger_info = trig_info;
            else
                back_time = 0;
            end
            
            %Translation of stimulus times to indices of the input data
            start_I = data.ftime.getNearestIndices(start_times + back_time);

            %Assumption: we only need to go forward in time ...
            sample_width = start_I(2:end)-start_I(1:end-1);
            min_sample_width = min(sample_width);
            n_samples_max = data.ftime.durationToNSamples(obj.max_artifact_duration);
            n_samples_per_trigger = min(min_sample_width,n_samples_max);
            
            n_stims = length(start_I);
            
            %This could be improved ...., 
            %   we could have multiple out of range ...
            %--------------------------------------------------------------
            last_is_short = start_I(end) + n_samples_per_trigger > data.n_samples;
            if last_is_short
                n_stims_for_template = n_stims - 1;
            else
                n_stims_for_template = n_stims;
            end
            
            %             t2 = 1:0.2:data_obj.n_samples;
            %             upsampled_data = interp1(1:data_obj.n_samples,data_obj.d,t2,'spline');
            
            stim_windows = sl.matrix.from.startAndLength(data.d,start_I(1:n_stims_for_template),n_samples_per_trigger,'by_row',false);
            avg_response = mean(stim_windows,2);
            result.avg_response = avg_response;
            result.original_data = copy(data);
            result.start_indices = start_I;
            result.triggered_responses = stim_windows;
            
            %             t2 = 1:0.2:length(avg_response);
            %             vq = interp1(1:length(avg_response),avg_response,t2,'spline');
            
            
            % %             n_samples_examine = 20;
            % %             t3 = 1:0.1:n_samples_examine;
            % %             n_plot_same_time = 20;
            % %             all_data = zeros(length(t3),n_plot_same_time);
            % %             for i = 1:n_stims
            % %                 I = ceil(mod(i-0.1,n_plot_same_time));
            % %                 all_data(:,I) = interp1(1:n_samples_examine,stim_windows(1:n_samples_examine,i),t3,'spline');
            % %                 plot(all_data)
            % %                 title(sprintf('%d',i));
            % %                 pause
            % %             end
            
            %Return to baseline
            %-------------------------
            %- find zero crossings
            %- look for correlation
            %- find a local max (or min) and
            
            result.blanking_used = obj.blank_artifact;
            if obj.blank_artifact
                %Steps
                %1) How much do we need to blank
                %2) Remove artifact
                if obj.n_samples_blank == -1
                    %Improvement, we might ultimately want to fit the
                    %stimulus artifact to a filter bank of various artifact
                    %types
                    %- monophasic
                    %- biphasic
                    %- triphasic
                    %Figure out how much to blank
                    
                    %find a local min or max
                    
                    if isempty(in.trigger_chan) && obj.n_samples_blank_algorithm == 2
                        local_n_samples_blank_algorithm = 1;
                    else
                        local_n_samples_blank_algorithm = obj.n_samples_blank_algorithm;
                    end
                    
                    switch local_n_samples_blank_algorithm
                        case 1
                            %n_samples_blank_algorithm
                            %Approach 1
                            %-------------------------------------------------------
                            %This approach seems to work well
                            
                            nsb_result = sci.time_series.filter.results.artifact_removal.n_samples_blanking_approach1();
                            nsb_result.average_stimulus_response = avg_response;
                            nsb_result.corr_width_used = obj.nsb_n_samples_corr;
                            
                            if obj.nsb_n_samples_corr > n_samples_per_trigger
                                error('correlation width for blanking approach 1 is too large')
                            end
                            
                            n_window_starts = n_samples_per_trigger-obj.nsb_n_samples_corr;
                            avg_corr = zeros(1,n_window_starts);
                            corr_sample_width = obj.nsb_n_samples_corr;
                            for iStart = 1:n_window_starts
                                corr_I = iStart:iStart+corr_sample_width-1;
                                avg_corr(iStart) = mean(corr(stim_windows(corr_I,:),avg_response(corr_I)));
                            end
                            
                            %I think instead we want to fit a line to the
                            %right hand side and then look for its crossing
                            %rather than taking the max drop
                            [~,I] = max(-1*diff(avg_corr));
                            I = I + 1; %fixing off by 1 for diff
                            n_samples_blank_local = I;
                            
                            nsb_result.average_correlation = avg_corr;
                            nsb_result.n_samples_to_blank = n_samples_blank_local;
                            result.n_samples_blanking_result = nsb_result;
                        case 2
                            %----------------------------------------------
                            %Just blank out the samples of the stimulus
                            %Eventually I'd like this method to use a decay
                            %but  we might make that another method (e.g.
                            %3)
                            
                            %TODO: provide result class ...
                            n_samples_blank_local = data.ftime.durationToNSamples(trig_info.window_duration);
                            n_samples_blank_local = max(n_samples_blank_local,1);
                        otherwise
                            error('No other options have been implemented')
                    end
                    h2 = sprintf('blanking width determined by algorithm %d',obj.n_samples_blank_algorithm);
                else
                    n_samples_blank_local = obj.n_samples_blank;
                    h2 = sprintf('blanking width specified by the user');
                end
                
                %TODO: Move these sections to local helpers
                
                cur_data = data.d;
                %The actual blanking
                %-------------------
                switch obj.blanking_type
                    %1 - 0
                    %2 - NaN
                    %3 - linear interpolation
                    case {1,2}
                        if obj.blanking_type == 1
                            blanking_value = 0;
                            h3 = 'values set to 0';
                        else
                            blanking_value = NaN;
                            h3 = 'values set to NaN';
                        end
                        for iStart = 1:n_stims
                            cur_start_I = start_I(iStart);
                            %cur_end_I = cur_start_I + min_sample_width-1;
                            cur_data(cur_start_I:cur_start_I+n_samples_blank_local-1) = blanking_value;
                            %cur_data(cur_start_I:cur_end_I) = cur_data(cur_start_I:cur_end_I)-avg_response;
                        end
                    case 3
                        x = 0:n_samples_blank_local+1;
                        for iStart = 1:n_stims
                            %These are now off by 1 so that we can grab
                            %the first and last and interpolate
                            cur_start_I = start_I(iStart)-1;
                            cur_end_I = cur_start_I+n_samples_blank_local+1;
                            
                            b = cur_data(cur_start_I);
                            m = (cur_data(cur_end_I)-b)/(n_samples_blank_local+1);
                            %cur_end_I = cur_start_I + min_sample_width-1;
                            cur_data(cur_start_I:cur_end_I) = m*x + b;
                            %cur_data(cur_start_I:cur_end_I) = cur_data(cur_start_I:cur_end_I)-avg_response;
                        end
                        h3 = 'values set by linear interpolation';
                end
                
                %h2 - method of determining width
                %h3 - blanking value


                filtered_data = copy(data);
                filtered_data.d = cur_data;
             	history = sprintf('%d Artifacts blanked over %d samples, %s, %s',n_stims,n_samples_blank_local,h2,h3);
                filtered_data.addHistoryElements(history);
                
                
            else
                %We need to check if the artifact is changing over time ...
                %or if the response is changing over time
                %In the first case, we could fit some line to the change
                %over time or do a running template ...
                error('Not yet implemented')
            end
            
            result.filtered_data = filtered_data;
            
            info = result;
        end
        
    end
    
end

