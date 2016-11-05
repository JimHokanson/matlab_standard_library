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
    
    properties
        new_data
    end
    
    methods
        function obj = stim_artifact_remover(data_obj,start_I,end_I,varargin)
            %obj.original_data = data_obj;
            %obj.is_stim_mask = is_stim_mask;
            %keyboard
            
            in.set_artifact_to_zero = false;
            in.n_samples_blank = [];
            in = sl.in.processVarargin(in,varargin);
            
            %keyboard
            
            %Let's assume for now we only need to go forward in time ...
            sample_width = start_I(2:end)-start_I(1:end-1);
            min_sample_width = min(sample_width);
            n_stims = length(start_I);
            %TODO: Check an out of bounds on grabbing after the last one
            
            %TODO: This should be a method sl.array.enforceBounds
            %while ~done
            if start_I(end) + min_sample_width > data_obj.n_samples
                start_I(end) = [];
            end
            
            
            %This is currently only for 1 channel, this would neeed to be
            %fixed ...
            stim_windows = sl.array.toMatrixFromStartsAndLength(data_obj.d,start_I,min_sample_width);
            avg_response = mean(stim_windows,1)';
            
            %TODO: We need to look for amplifier saturation :/
            
            %avg_response(:,15)
            
            %TODO: Now fit this to a polynomial that goes to zero ...
            
            
            
            
            cur_data = data_obj.d;
            if in.set_artifact_to_zero
                if isempty(in.n_samples_blank)
                    n_samples_blank = 15;
                else
                    n_samples_blank = in.n_samples_blank;
                end
                
                    n_samples_offset = n_samples_blank-1;
                
                for iStart = 1:length(start_I)
                    cur_start_I = start_I(iStart);
                    %cur_end_I = cur_start_I + min_sample_width-1;
                    cur_data(cur_start_I:cur_start_I+n_samples_offset) = 0;
                    %cur_data(cur_start_I:cur_end_I) = cur_data(cur_start_I:cur_end_I)-avg_response;
                end
            else
                for iStart = 1:length(start_I)
                    cur_start_I = start_I(iStart);
                    cur_end_I = cur_start_I + min_sample_width-1;
                    %cur_data(cur_start_I:cur_start_I+14) = 0;
                    cur_data(cur_start_I:cur_end_I) = cur_data(cur_start_I:cur_end_I)-avg_response;
                end
            end
            obj.new_data = cur_data;
        end
        %TODO: Create static creation class
    end
    
end

