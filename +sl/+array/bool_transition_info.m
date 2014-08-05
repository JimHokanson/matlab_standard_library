classdef bool_transition_info
    %
    %   Class:
    %   sl.array.bool_transition_info
    %
    %
    
    properties
        on_start_indices  %First instance of a 1 in a group
        %e.g. 0 0 1 1 1 0 0 1 1
        %     1 2 3 4 5 6 7 8 9
        %
        %    This would contain [3 8]
        on_end_indices
        off_start_indices %First instance of a 0
        off_end_indices
    end
    
    %TODO: Impelement these things ...
% % %     properties
% % %         on_durations
% % %         off_durations
% % %         on_duration_by_sample %For every on sample, the value is how
% % %         %long its duration lasted. This ends up looking a lot like a staircase
% % %         off_duration_by_sample %Same as on, but reversed
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
        function obj = bool_transition_info(logical_data)
            
            %??? What sort of options would we like to have here ...
            
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
            
            
            
            obj.on_start_indices  = find(d == 1);
            obj.off_start_indices = find(d == -1);
            
            %NOTE: We could make this faster by casing everything out ...
            %
            %Casing on the start value and end value
            % if start_is_1 and end_is_1
            % elseif start_is_1 and end_is_0
            % etc.
            %
            obj.on_end_indices = obj.off_start_indices - 1;
            if ~isempty(obj.on_end_indices) && obj.on_end_indices(1) == 0
                obj.on_end_indices(1) = [];
            end
            if logical_data(end) == 1
                obj.on_end_indices(end+1) = length(logical_data);
            end
            
            obj.off_end_indices = obj.on_start_indices - 1;
            if ~isempty(obj.off_end_indices) && obj.off_end_indices(1) == 0
                obj.off_end_indices(1) = [];
            end
            if logical_data(end) == 1
                obj.off_end_indices(end+1) = length(logical_data);
            end
            
            
            
            
        end
    end
    
end

