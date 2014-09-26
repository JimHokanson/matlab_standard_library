classdef bool_transition_info
    %
    %   Class:
    %   sl.array.bool_transition_info
    %
    %   TODO: Implement units tests for this ...
    
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
            
            if isrow(logical_data)
                d = diff([~logical_data(1) logical_data]);
            else
                d = diff([~logical_data(1); logical_data;]);
            end
            %1 - must always be a start
            %end - must always be an end

            obj.true_start_indices  = find(d == 1);
            obj.false_start_indices = find(d == -1);
            
            %NOTE: We could make this faster by casing everything out ...
            %
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

