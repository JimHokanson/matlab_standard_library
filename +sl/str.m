classdef str
    %
    %   Class:
    %   sl.str
    
    properties
    end
    
    methods (Static)
        function str_out = truncateStr(str_in,max_length,varargin)
            %x Truncates a string to a given length adding on a too long indicator
            %
            %   str_out = sl.str.truncateStr(str_in,length,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   too_short_is_ok : logical (default false)
            %       If true, this indicates that we don't mind the string
            %       being too long. This was added for command window
            %       display where I would rather an error not be thrown
            %       simply because the command window is too narrow
            %   short_indicator : 
            
            in.too_short_is_ok = false;
            in.short_indicator = '...'; %Text to display at end of string
            %when the string has been shortened
            in = sl.in.processVarargin(in,varargin);
            
            if length(str_in) <= max_length
                str_out = str_in;
            else
                if length(in.short_indicator) > max_length
                    if in.too_short_is_ok
                        str_out = in.short_indicator;
                    else
                        error(['The length of the text to indicate a string as being' ...
                            ' shortened: %d, is greater than the max length %d'],...
                            length(in.short_indicator),max_length)
                    end
                else
                    n_chars_keep = max_length - length(in.short_indicator);
                    str_out = [str_in(1:n_chars_keep) in.short_indicator];
                end
            end
            
        end
    end
    
end

