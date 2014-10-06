classdef bool_transition_info
    %
    %   Class:
    %   sl.array.bool_transition_info
    %
    %   TODO: Implement units tests for this ...
    %
    %
    %   TODO: Allow gettings runs of trues or falses based on linking
    %   between
    
    properties
        
        
        true_start_indices  %First instance of a 1 in a group
        %e.g. 0 0 1 1 1 0 0 1 1
        %     1 2 3 4 5 6 7 8 9
        %
        %    This would contain [3 8]
        true_end_indices
        false_start_indices %First instance of a 0
        false_end_indices
    end
    
    properties (Hidden)
        time
    end
    
    properties (Dependent)
        %------------------------------------------------------------------
        %NOTE: These things are defined better if time is well defined.
        %Otherwise, time defaults to a start time of 0 and a dt of 1.
        %------------------------------------------------------------------
        true_start_times
        true_end_times
        false_start_times
        false_end_times
        true_durations
        false_durations
    end
    
    %TODO: Make these run only once ...
    methods
        function value = get.true_start_times(obj)
            value = h__getTimeGivenIndices(obj.time,obj.true_start_indices);
        end
        function value = get.true_end_times(obj)
            value = h__getTimeGivenIndices(obj.time,obj.true_end_indices);
        end
        function value = get.false_start_times(obj)
            value = h__getTimeGivenIndices(obj.time,obj.false_start_indices);
        end
        function value = get.false_end_times(obj)
            value = h__getTimeGivenIndices(obj.time,obj.false_end_indices);
        end
        function value = get.true_durations(obj)
            value = obj.true_end_times - obj.true_start_times;
        end
        function value = get.false_durations(obj)
            value = obj.false_end_times - obj.false_start_times;
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
            %
            %   Optional Inputs:
            %   ----------------
            %   time: sci.time_series.time
            %       TODO: We could also support a time array
            
            
            in.time = [];
            in = sl.in.processVarargin(in,varargin);
            
            obj.time = in.time;
            
            if length(logical_data) <= 1
                return
            end
            
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
        function [start_run_times,stop_run_times] = getRunStartsAndStops(obj,min_time_for_new_run,varargin)
            %
            %    [start_run_times,stop_run_times] = obj.getRunStartsAndStops(min_time_for_new_run,varargin)
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

