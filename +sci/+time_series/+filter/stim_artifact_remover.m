classdef stim_artifact_remover < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.filter.stim_artifact_remover
    %
    %   See Also:
    %   ---------
    %   sci.time_series.event_calculators.simpleThreshold
    %
    %   This class needs a lot of work. I think eventually
    %   we'll run a "filter" method that returns a result object
    %
    %   The constructor should just take options.
    
    %Processing Options
    %----------------------------------------------------------------------
    properties
        d0 = '---------  Blanking Options  -----------'
        blank_artifact = true
        
        blanking_type = 1
        %1) set to 0
        %2) set to NaN
        %3) linear interpolation - NYI
        
        n_samples_blank = -1
        %If specified, this is the # of samples that will be removed
        
        %Multiple options not yet implemented
        n_samples_blank_algorithm = 1
        %1) - Looks for a decrease in the correlation of sliding
        %windows that start at different locations.
        
        
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
        function [filtered_data,info] = filter(obj,data_obj,start_I)
            %
            %
            %
            %   Possible Improvements
            %   ---------------------
            %   Pass in a trigger channel ...
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
            
            BLANKING_APP1_CORR_WIDTH = 15;
            
            %obj.original_data = data_obj;
            %obj.is_stim_mask = is_stim_mask;
            %keyboard
            
            %             in.set_artifact_to_zero = false;
            %             in.n_samples_blank = [];
            %             in = sl.in.processVarargin(in,varargin);
            
            result = sci.time_series.filter.results.artifact_removal_result();
            
            %Assumption: we only need to go forward in time ...
            sample_width = start_I(2:end)-start_I(1:end-1);
            min_sample_width = min(sample_width);
            n_samples_max = data_obj.ftime.durationToNSamples(obj.max_artifact_duration);
            n_samples_per_trigger = min(min_sample_width,n_samples_max);
            
            n_stims = length(start_I);
            
            %This could be improved ...., we could have multiple out
            %of range ...
            %--------------------------------------------------------------
            last_is_short = start_I(end) + n_samples_per_trigger > data_obj.n_samples;
            if last_is_short
                n_stims_for_template = n_stims - 1;
            else
                n_stims_for_template = n_stims;
            end
            
            %             t2 = 1:0.2:data_obj.n_samples;
            %             upsampled_data = interp1(1:data_obj.n_samples,data_obj.d,t2,'spline');
            
            stim_windows = sl.matrix.from.startAndLength(data_obj.d,start_I(1:n_stims_for_template),n_samples_per_trigger,'by_row',false);
            avg_response = mean(stim_windows,2);
            result.avg_response = avg_response;
            result.original_data = copy(data_obj);
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
                    
                    
                    switch obj.n_samples_blank_algorithm
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
                        otherwise
                            error('No other options have been implemented')
                    end
                else
                    n_samples_blank_local = obj.n_samples_blank;
                end
                
                cur_data = data_obj.d;
                for iStart = 1:n_stims
                    cur_start_I = start_I(iStart);
                    %cur_end_I = cur_start_I + min_sample_width-1;
                    cur_data(cur_start_I:cur_start_I+n_samples_blank_local-1) = 0;
                    %cur_data(cur_start_I:cur_end_I) = cur_data(cur_start_I:cur_end_I)-avg_response;
                end
                filtered_data = copy(data_obj);
                filtered_data.d = cur_data;
                
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

