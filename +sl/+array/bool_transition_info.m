classdef bool_transition_info < sl.obj.display_class
    %
    %   Class:
    %   sl.array.bool_transition_info
    %
    %   This class calculate useful information about transitions between
    %   high and low transition periods.
    %
    %
    %   TODO: Implement units tests for this ...
    %
    %   Improvements:
    %   1) Implement some sort of plotting methodology
    
    
    properties
        first_sample %logical
        %
        %   This is the value of the first sample
        %
        %   `If we start with a set of true values this will be true.
        
        
        n_samples
        %NOTE: We assume that the first index indicates the "start"
        %of something and that the last index indcates the "end" of an
        %event. TODO: We could add this on as an optional input
        true_start_indices  %First instance of a 1 in a group
        %e.g. 0 0 1 1 1 0 0 1 1
        %     1 2 3 4 5 6 7 8 9
        %
        %    This would contain [3 8]
        true_end_indices    %Last instance of a 1 in a group
        false_start_indices %First instance of a 0
        false_end_indices
    end
    
    properties (Hidden)
        time
    end
    
    %??? If I do dependent, does the value get stored or do I always
    %have an empty value and need to do the calculation
    properties % (Dependent)
        %------------------------------------------------------------------
        %NOTE: These things are defined better if time is well defined.
        %Otherwise, time defaults to a start time of 0 and a dt of 1.
        %------------------------------------------------------------------
        n_true
        n_false
        start_time
        true_start_times
        true_end_times
        false_start_times
        false_end_times
        true_durations %in time
        false_durations %in time
        true_sample_durations
        false_sample_durations
    end
    
    methods
        function value = get.n_true(obj)
            value = length(obj.true_start_indices);
        end
        function value = get.n_false(obj)
            value = length(obj.false_start_indices);
        end
        function value = get.true_start_times(obj)
            value = obj.true_start_times;
            if isempty(value)
                value = h__getTimeGivenIndices(obj.time,obj.true_start_indices);
                obj.true_start_times = value;
            end
        end
        function value = get.true_end_times(obj)
            value = obj.true_end_times;
            if isempty(value)
                value = h__getTimeGivenIndices(obj.time,obj.true_end_indices);
                obj.true_end_times = value;
            end
        end
        function value = get.false_start_times(obj)
            value = obj.false_start_times;
            if isempty(value)
                value = h__getTimeGivenIndices(obj.time,obj.false_start_indices);
                obj.false_start_times = value;
            end
        end
        function value = get.false_end_times(obj)
            value = obj.false_end_times;
            if isempty(value)
                value = h__getTimeGivenIndices(obj.time,obj.false_end_indices);
                obj.false_end_times = value;
            end
        end
        function value = get.true_durations(obj)
            value = obj.true_durations;
            if isempty(value)
                value = obj.true_end_times - obj.true_start_times;
                obj.true_durations = value;
            end
        end
        function value = get.false_durations(obj)
            value = obj.false_durations;
            if isempty(value)
                value = obj.false_end_times - obj.false_start_times;
                obj.false_durations = value;
            end
        end
        function value = get.true_sample_durations(obj)
            value = obj.true_sample_durations;
            if isempty(value)
                value = obj.true_end_indices - obj.true_start_indices + 1;
                obj.true_sample_durations = value;
            end
        end
        function value = get.false_sample_durations(obj)
            value = obj.false_sample_durations;
            if isempty(value)
                value = obj.false_end_indices - obj.false_start_indices + 1;
                obj.false_sample_durations = value;
            end
        end
    end
    
    
    %TODO: Impelement these things ...
    % % %     properties
    % % %         true_duration_by_sample %For every on sample, the value is how
    % % %         %long its duration lasted. This ends up looking a lot like a staircase
    % % %         false_duration_by_sample %Same as on, but reversed
    % % %
    % % %                     %Old code for doing this ...
    % % %                     %{
    % % %                     Itrue  = logicalArray ~= 0;
    % % %             Ifalse = find(~Itrue);
    % % %
    % % %             D = diff([0 Ifalse length(logicalArray)+1]);
    % % %
    % % %             output    = generateArrayByReplicatingCount(D(D > 1)-1);
    % % %             if nargout == 2
    % % %                 groupInfo = struct;
    % % %                 groupInfo.counts = D(D > 1)-1;
    % % %                 groupInfo.startIndices = find(diff([0 logicalArray]) == 1);
    % % %             end
    % % %
    % % %             %JAH BUG FIX: A true logical input can't handle the assigment
    % % %             %of numerical values
    % % %             countArray = double(logicalArray);
    % % %             countArray(Itrue) = output;
    % % %
    % % %
    % % %         %}
    % % %     end
    
    methods
        function obj = bool_transition_info(logical_data,varargin)
            %
            %   obj = sl.array.bool_transition_info(logical_data,varargin)
            %
            %   Inputs
            %   ------
            %   logical_data: logical array
            %
            %   Optional Inputs:
            %   ----------------
            %   time: sci.time_series.time
            %       TODO: We could also support a time array
            %
            %   Examples
            %   --------
            %   sl.array.bool_transition_info(stim_data.d > 0.1,'time',stim_data.time)
            
            
            in.time = [];
            in = sl.in.processVarargin(in,varargin);
            
            obj.time = in.time;
            
            if ~isempty(in.time)
                obj.start_time = in.time.start_offset;
            else
                %Really samples ...
                obj.start_time = 1;
            end
            
            if length(logical_data) <= 1
                return
            end
            
            obj.init(logical_data)
        end
        function [start_run_times,stop_run_times] = getRunStartsAndStops(obj,min_time_for_new_run,varargin)
            %
            %    [start_run_times,stop_run_times] = obj.getRunStartsAndStops(min_time_for_new_run,varargin)
            %
            %   This function was written hastily and probably needs to be
            %   rewritten
            %
            %
            %    This was originally designed for getting runs of
            %    stimulation where each stimulus pulse only lasts for a
            %    certain amount of time, but the goal is to pull out a train
            %    of pulses and groups them together based on the time
            %    between pulses being relatively small, at least compared to
            %    the time between trains which should be larger.
            %
            %    min_time_for_new_run :
            %        If the amount of time between subsequent events is
            %        greater than this value, then a new run is started.
            %
            %    TODO: Return an object
            %
            
            
            in.run_value = true; %or false
            in.as_time = true; %false - as indices into the true or false
            in = sl.in.processVarargin(in,varargin);
            
            %TODO: Not all of these options are implemented
            
            %TODO: WE need to respect the row or column nature of the data
            
            
            
            
            mask = obj.false_durations > min_time_for_new_run;
            
            %TODO: This might not always be right, needs to be fixed ...
            mask(1) = false; %Ignore long wait at the beginning
            stop_run_times = obj.false_start_times(mask);
            stop_stim_durations = obj.false_durations(mask);
            start_run_times = [obj.true_start_times(1); stop_run_times(1:end-1)+stop_stim_durations(1:end-1)];
        end
        function mask = getMask(obj)
            mask = false(1,obj.n_samples);
            true_start_I = obj.true_start_indices;
            true_end_I   = obj.true_end_indices;
            for iStart = 1:length(true_start_I)
                mask(true_start_I(iStart):true_end_I(iStart)) = true;
            end
        end
        function negateSections(obj,indices,type)
            %
            %
            %   type: logical
            %This should be changed to be more efficient but this
            %was the easiest approach to get right quickly
            logical_data = obj.getMask();
            if type
                start_I = obj.true_start_indices(indices);
                end_I   = obj.true_end_indices(indices);
                
            else
                start_I = obj.false_start_indices(indices);
                end_I   = obj.false_end_indices(indices);
            end
            
            new_value = ~type;
            
            for iStart = 1:length(start_I)
                logical_data(start_I(iStart):end_I(iStart)) = new_value;
            end
            obj.init(logical_data);
            
            %This needs to be a method ...
            obj.true_start_times = [];
            obj.true_end_times = [];
            obj.false_start_times = [];
            obj.false_end_times = [];
            obj.true_durations = []; %in time
            obj.false_durations = []; %in time
            obj.true_sample_durations = [];
            obj.false_sample_durations = [];
        end
    end
    
    methods (Hidden)
        function init(obj,logical_data)
            %Written so that negateSections could work easily, technically
            %it shouldn't be needed if negateSections were written
            %correctly
            obj.first_sample = logical_data(1);
            obj.n_samples    = length(logical_data);
            
            %TODO: We don't even need the temp logic, we would just need to
            %a
            if isrow(logical_data)
                temp_logic = [~logical_data(1) logical_data];
            else
                temp_logic = [~logical_data(1); logical_data;];
            end
            %1 - must always be a start
            %end - must always be an end
            
            %These could all be made dependent
            
            %We should write this in mex and use SIMD ...
            obj.true_start_indices  = find(~temp_logic(1:end-1) & temp_logic(2:end));
            obj.false_start_indices = find(temp_logic(1:end-1) & ~temp_logic(2:end));
            
            %NOTE: We could make this faster by casing everything out ...
            
            %Casing on the start value and end value
            % if start_is_1 and end_is_1
            % elseif start_is_1 and end_is_0
            % etc.
            %
            obj.true_end_indices = obj.false_start_indices - 1;
            if ~isempty(obj.true_end_indices) && obj.true_end_indices(1) == 0
                obj.true_end_indices(1) = [];
            end
            if logical_data(end)
                obj.true_end_indices(end+1) = length(logical_data);
            end
            
            obj.false_end_indices = obj.true_start_indices - 1;
            if ~isempty(obj.false_end_indices) && obj.false_end_indices(1) == 0
                obj.false_end_indices(1) = [];
            end
            if ~logical_data(end)
                obj.false_end_indices(end+1) = length(logical_data);
            end
        end
    end
    
end

function time_out = h__getTimeGivenIndices(time,indices)
%
%   Inputs:
%   -------
%   time: empty array or sci.time_series.time
if isempty(time)
    %ASSUME:
    %start_time = 0;
    %dt = 1;
    time_out = indices - 1;
else
    time_out = time.getTimesFromIndices(indices);
end

end

