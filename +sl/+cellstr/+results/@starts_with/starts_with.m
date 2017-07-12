classdef starts_with
    %
    %   Class:
    %   sl.cellstr.results.starts_with
    
    properties
        cellstr
        string_to_match
        mask
        matches
        matches_I
        string_remainders
        string_remainder_lengths
    end
    
    methods
        function obj = starts_with(cellstr,string_to_match,mask)
            %
            %   obj = sl.cellstr.results.starts_with(cellstr,string_to_match,mask)
            obj.cellstr = cellstr;
            obj.string_to_match = string_to_match;
            obj.mask = mask;
            
            obj.matches = cellstr(mask);
            obj.matches_I = find(mask);
            
            match_length = length(string_to_match);
            
            obj.string_remainders = cellfun(@(x) x(match_length+1:end),obj.matches,'un',0);
            obj.string_remainder_lengths = cellfun('length',obj.string_remainders);
        end
    end
    
end

