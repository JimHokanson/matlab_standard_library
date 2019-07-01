classdef simple_threshold_results < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.event_results.simple_threshold_results
    %
    %   See Also
    %   ---------
    %   sci.time_series.calculators.event_calculators.simpleThreshold
    %   
    
    properties
        data %Data used for thresholding
        
        %Who stores this?
        original_data %This is only for reference (storage and plotting)
        
        data_stores_equal = true
        %Goal is to be able to know whether data and original_data are the
        %same.
        
        bti %sl.array.bool_transition_info
        
        deleted_entries %debugging
        
        start_time
        %TODO: We could do lazy evaluation if we hold onto the
        %bool_transition_info and the mask
        threshold_start_times
        threshold_start_I
        threshold_end_times
        threshold_end_I
        n_samples
        
        
    end
    
    properties (Dependent)
        n_epochs
        durations
        epoch_averages
        rectified_epoch_averages
        epoch_duration_avg_product
        epoch_duration_rect_avg_product
        epoch_averages_original_data
        rectified_epoch_averages_original_data
        min_epoch_values %mininum value during each epoch
        max_epoch_values %maximum value during each epoch
    end
    
    methods
        function value = get.min_epoch_values(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = obj.data.d;
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = min(raw_data(start_I(i):end_I(i)));
            end
        end
        function value = get.max_epoch_values(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = obj.data.d;
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = max(raw_data(start_I(i):end_I(i)));
            end
        end
        function value = get.n_epochs(obj)
            value = length(obj.threshold_start_times);
        end
        function value = get.durations(obj)
            value = obj.threshold_end_times - obj.threshold_start_times;
            %TODO: This should be fixed earlier in BTI
            if size(value,1) > 1
                value = value';
            end
        end
        function value = get.epoch_averages(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = obj.data.d;
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = mean(raw_data(start_I(i):end_I(i)));
            end
        end
        function value = get.rectified_epoch_averages(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = abs(obj.data.d);
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = mean(raw_data(start_I(i):end_I(i)));
            end
        end
      	function value = get.epoch_duration_avg_product(obj)
            value = obj.durations.*obj.epoch_averages;
        end
        function value = get.epoch_duration_rect_avg_product(obj)
            value = obj.durations.*obj.rectified_epoch_averages;
        end
        function value = get.epoch_averages_original_data(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = obj.original_data.d;
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = mean(raw_data(start_I(i):end_I(i)));
            end
        end
        function value = get.rectified_epoch_averages_original_data(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = abs(obj.original_data.d);
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = mean(raw_data(start_I(i):end_I(i)));
            end
        end
    end
    
    %TODO: How many do we remove from time filtering ????
    
    methods
        function mask = getMask(obj,epoch_value)
            if nargin == 1
                epoch_value = true;
            end
            
            %Initialize with the opposite value
            if epoch_value
                mask = false(1,obj.n_samples);
            else
                mask = true(1,obj.n_samples);
            end
            
            %TODO: This should be a single call sl.array....
            for i = 1:length(obj.threshold_start_times)
                cur_start = obj.threshold_start_I(i);
                cur_end   = obj.threshold_end_I(i);
                mask(cur_start:cur_end) = epoch_value;
            end
        end
        function plot(obj,varargin)
            %
            %   plot(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   zero_time :
            %       

            in.zero_time = true;
            in = sl.in.processVarargin(in,varargin);
            
            if ~isempty(obj.original_data)
                plot(obj.original_data,'zero_time',in.zero_time)
            end
            
            %TODO: If this is the same as the original data then
            %we shouldn't plot it ...
            hold on
            plot(obj.data,'zero_time',in.zero_time)
            
            plotEpochs(obj,'zero_time',in.zero_time)
            hold off
        end
        function varargout = plotEpochs(obj,varargin)
            %
            %
            %   Optional Inputs
            %   ---------------
            %   zero_time : default false
            %   face_alpha : 0.2
            %   color : 0.2
            %   y_min_pct : 0.01
            %   y_max_pct : 0.99
            
            in.zero_time = false;
            in.face_alpha = 0.2;
            in.color = 'b';
            in.y_min_pct = 0.01;
            in.y_max_pct = 0.99;
            in = sl.in.processVarargin(in,varargin);
            
            ylim = get(gca,'ylim');
            y_range = ylim(2)-ylim(1);
            
            s = struct;
            p_cell = cell(1,obj.n_epochs);
            
            y1 = ylim(1)+in.y_min_pct*y_range;
            y2 = ylim(1)+in.y_max_pct*y_range;
            for i = 1:obj.n_epochs
                cur_start = obj.threshold_start_times(i);
                cur_end   = obj.threshold_end_times(i);
                if in.zero_time
                    cur_start = cur_start - obj.start_time;
                    cur_end = cur_end - obj.start_time;
                end
                p = patch([cur_start cur_start cur_end cur_end],[y1 y2 y2 y1],in.color);
                p_cell{i} = p;
                set(p,'FaceAlpha',in.face_alpha);
            end
            s.h_patch = [p_cell{:}];
            if nargout
                varargout{1} = s;
            end
        end
        function epoch_data = getEpochData(obj,index)
           start_I = obj.threshold_start_I(index);
           end_I = obj.threshold_end_I(index);
           epoch_data = obj.data.subset.fromStartAndStopSamples(start_I,end_I);
        end
        function value = getAverageActivity(obj,data)
            %x Calculates mean values of input data over these epochs
            %
            %   value = getAverageActivity(obj,data)
            %
            %   This was written because I was processing on one set of
            %   data but I needed another set of processed data to average
            %   (besides the already added original data)
            
            value = zeros(1,obj.n_epochs);
            raw_data = data.d;
            start_I = obj.threshold_start_I;
            end_I = obj.threshold_end_I;
            for i = 1:obj.n_epochs
                value(i) = mean(raw_data(start_I(i):end_I(i)));
            end
        end
        function expand(obj,threshold,varargin)
            %
            %   This could have a lot of options ...
            %
            %
            %   This function needs A LOT OF WORK
            %
            %   The current function takes our epochs and expands
            %   until we get below our threshold.
            
            %TODO: This needs to update the bti
                        
            %This assumes we want greater
            bad_mask = obj.data.d < threshold;
            
            %UGLY CODE, LOOK AWAY :/
            
            %This is where it would help to have logical searches starting
            %at a specific point
            for i = 1:obj.n_epochs
               I1 = obj.threshold_start_I(i);
               I2 = obj.threshold_end_I(i);
               bad_mask2 = bad_mask;
               bad_mask2(I1+1:end) = false;
               I3 = find(bad_mask2,1,'last');
               bad_mask3 = bad_mask;
               bad_mask3(1:I2-1) = false;
               I4 = find(bad_mask3,1);

               %TODO: If empty then we leave where we are at ...
               if i > 1 && I3 <= obj.threshold_end_I(i-1)
                   I_prev = obj.threshold_end_I(i-1);
                   [~,I5] = min(obj.data.d(I_prev:I1-1));
                   I3 = I_prev + I5 - 1;
               end
               if i ~= obj.n_epochs && I4 >= obj.threshold_start_I(i+1)
                   %We've run into the next one ...
                   %Split at min
                   I_next = obj.threshold_start_I(i+1);
                   [~,I5] = min(obj.data.d(I2+1:I_next-1));
                   I4 = I2 + I5;

                  %obj.threshold_end_I(i) = I4;
               end
               obj.threshold_start_I(i) = I3;
               obj.threshold_end_I(i) = I4;

            end
            
            obj.threshold_start_times = obj.data.ftime.getTimesFromIndices(obj.threshold_start_I);
            obj.threshold_end_times = obj.data.ftime.getTimesFromIndices(obj.threshold_end_I);
            
        end
        function deleteEntries(obj,delete_indices_or_mask,reason,extras)
            %x Delete entries based on indices or mask
            %
            %   deleteEntries(obj,delete_indices_or_mask,*reason,*extras)
            %
            %   Inputs
            %   ------
            %   delete_indices_or_mask : indices or mask
            %       Values to be deleted, generally based on some
            %       calculated property ...
            %   reason : default 'Unspecified'
            %       This string goes into a deleted entry ...
            %
            %   Examples
            %   --------
            %   results.deleteEntries(results.epoch_averages < in.min_average,'low energy removal');
            
            if nargin < 3
                reason = 'Unspecified';
            end
            if nargin < 4
                extras = [];
            end
            
            s = struct;
            s.threshold_start_times = obj.threshold_start_times(delete_indices_or_mask);
            s.threshold_start_I = obj.threshold_start_I(delete_indices_or_mask);
            s.threshold_end_times = obj.threshold_end_times(delete_indices_or_mask);
            s.threshold_end_I = obj.threshold_end_I(delete_indices_or_mask);
            s.reason = reason;
            s.delete = delete_indices_or_mask;
            if isnumeric(s.delete)
                s.n_remove = length(s.delete);
            else 
                s.n_remove = sum(s.delete);
            end
            s.extras = extras;
            
            obj.threshold_start_times(delete_indices_or_mask) = [];
            obj.threshold_start_I(delete_indices_or_mask) = [];
            obj.threshold_end_times(delete_indices_or_mask) = [];
            obj.threshold_end_I(delete_indices_or_mask) = [];
            
            if isempty(obj.deleted_entries)
                obj.deleted_entries = s;
            else
                obj.deleted_entries = [obj.deleted_entries s];
            end
        end
    end
    
end

