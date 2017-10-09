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
        
        original_data %This is only for reference (storage and plotting)
        
        bti %sl.array.bool_transition_info
        
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
        epoch_averages_original_data
        rectified_epoch_averages_original_data
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
        function value = get.rectified_epoch_averages(obj)
            value = zeros(1,obj.n_epochs);
            raw_data = abs(obj.data.d);
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
            
            %NOT YET IMPLEMENTED
            in.zero_time = true;
            in = sl.in.processVarargin(in,varargin);
            
            clf
            if ~isempty(obj.original_data)
                plot(obj.original_data,'zero_time',in.zero_time)
            end
            hold on
            plot(obj.data)
            plotEpochs(obj,'zero_time',in.zero_time)
        end
        function plotEpochs(obj,varargin)
            
            in.zero_time = true;
            in.face_alpha = 0.2;
            in.color = 'b';
            in = sl.in.processVarargin(in,varargin);
            
            ylim = get(gca,'ylim');
            y_range = ylim(2)-ylim(1);
            
            %Trying to prevent the ylim from changing because of this
            %plotting
            SC = 0.05;
            y1 = ylim(1)+SC*y_range;
            y2 = ylim(2)-SC*y_range;
            for i = 1:length(obj.threshold_start_times)
                cur_start = obj.threshold_start_times(i);
                cur_end   = obj.threshold_end_times(i);
                if in.zero_time
                    cur_start = cur_start - obj.start_time;
                    cur_end = cur_end - obj.start_time;
                end
                p = patch([cur_start cur_start cur_end cur_end],[y1 y2 y2 y1],in.color);
                set(p,'FaceAlpha',in.face_alpha);
            end
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
        function deleteEntries(obj,delete_indices_or_mask)
            obj.threshold_start_times(delete_indices_or_mask) = [];
            obj.threshold_start_I(delete_indices_or_mask) = [];
            obj.threshold_end_times(delete_indices_or_mask) = [];
            obj.threshold_end_I(delete_indices_or_mask) = [];
        end
    end
    
end

