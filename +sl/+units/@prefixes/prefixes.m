classdef prefixes
    %
    %   Class:
    %   sl.units.prefixes
    %
    %   Call via:
    %   ---------
    %   sl.units.prefixes.getInstance()
    
    properties
       %TODO: We need to have some sort of way of specifying 
       %which prefix should be used
       %
       %    => e.g. deka^2/deca => deka
       raw = {
           'Y' 'yotta'  24
           'Z' 'zetta'  21
           'E' 'exa'    18
           'P' 'peta'   15
           'T' 'tera'   12
           'G' 'giga'   9
           'M' 'mega'   6
           'k' 'kilo'   3
           'h' 'hecto'  2
           'da' 'deca'  1   
           'da' 'deka'  1
           'd' 'deci'   -1
           'c' 'centi'  -2
           'm' 'milli'  -3
           'u' 'micro'  -6
           char(181) 'micro' -6 %micro
           char(956) 'micro' -6 %Greek mu
           'n' 'nano' -9
           'p' 'pico' -12
           'f' 'femto' -15
           'a' 'atto' -18
           'z' 'zepto' -21
           'y' 'yocto' -24
           }
       short
       long
       power
    end
    
    methods (Access=private)
        function obj = prefixes()
           obj.short = obj.raw(:,1);
           obj.long  = obj.raw(:,2);
           obj.power = [obj.raw{:,3}];
        end
    end
    
    methods
        function prefix = getPrefixMatch(obj,string)
            %
            %   
            %
            
           %This could presumably be optimized ...
           
           %{
            test_string = 'kilogram';
            p = sl.units.prefixes.getInstance();
            prefix = p.getPrefixMatch(test_string)
            remaining_string = prefix.removePrefixFromString(test_string)
           %}
           
           %We need to look for long first as many of the shorts are in the
           %long. Note, we can't guarantee a perfect match, perhaps just 
           %the most likely.
           %
           %TODO: We might eventually want to return all possible prefixes
           
           matched_long_I = find(cellfun(@(x) strncmp(x,string,length(x)),obj.long));
           
           if ~isempty(matched_long_I)
               I = matched_long_I(1);
               string = obj.long{I};
               is_short = false;
           else
               matched_short_I = find(cellfun(@(x) strncmp(x,string,length(x)),obj.short));
               if isempty(matched_short_I)
                   I = [];
               else
                   I = matched_short_I(1);
                   string = obj.short{I};
               end
               is_short = true;
           end
           
           if isempty(I)
               prefix = [];
           else
               prefix = sl.units.prefix(string,obj.power(I),is_short);
           end
                      
        end
    end
    methods (Static)
        function obj = getInstance()
           %TODO: make singleton
           obj = sl.units.prefixes; 
        end
    end
    
end

