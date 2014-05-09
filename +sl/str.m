classdef str
    %
    %   Class:
    %   sl.str
    
    properties
    end
    
    methods (Static)
        function str_out = truncateStr(str_in,max_length,varargin)
            %
            %
            %   str_out = sl.str.truncateStr(str_in,length,varargin)
            %
            
            in.short_indicator = '...'; %Text to display at end of string
            %when the string has been shortened
            in = sl.in.processVarargin(in,varargin);
            
            if length(str_in) <= max_length
                str_out = str_in;
            else
                if length(in.short_indicator) > max_length
                   error(['The length of the text to indicate a string as being' ...
                       ' shortened: %d, is greater than the max length %d'],...
                       length(in.short_indicator),max_length) 
                end
                
                n_chars_keep = max_length - length(in.short_indicator);
                
                str_out = [str_in(1:n_chars_keep) in.short_indicator];
            end
            
        end
    end
    
end

