classdef simple_threshold_results < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.event_results.simple_threshold_results
    %
    %   See Also
    %   ---------
    %   sci.time_series.calculators.event_calculators.simpleThreshold
    
    properties
        data
        original_data
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
        epoch_averages_original_data
    end
    
    methods
        function value = get.n_epochs(obj)
            value = length(obj.threshold_start_times);
        end
        function value = get.durations(obj)
            value = obj.threshold_end_times - obj.threshold_start_times;
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
        function value = get.epoch_averages_original_data(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = obj.original_data.d;
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
        function plot(obj)
            clf
            if ~isempty(obj.original_data)
                plot(obj.original_data)
            end
            hold on
            plot(obj.data)
            plotEpochs(obj)
        end
        function plotEpochs(obj)
            ylim = get(gca,'ylim');
            for i = 1:length(obj.threshold_start_times)
                cur_start = obj.threshold_start_times(i);
                cur_end   = obj.threshold_end_times(i);
                p = patch([cur_start cur_start cur_end cur_end],[ylim(1) ylim(2) ylim(2) ylim(1)],'b');
                set(p,'FaceAlpha',0.3);
            end
        end
        function value = getAverageActivity(obj,data)
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
        function deleteEntries(obj,delete_indices_or_mask)
            obj.threshold_start_times(delete_indices_or_mask) = [];
            obj.threshold_start_I(delete_indices_or_mask) = [];
            obj.threshold_end_times(delete_indices_or_mask) = [];
            obj.threshold_end_I(delete_indices_or_mask) = [];
        end
    end
    
end

