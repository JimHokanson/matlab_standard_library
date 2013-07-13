classdef (Hidden) filter_options < sl.obj.handle_light
    %
    %
    %   Class:
    %   sl.dir.filter_options
    
    properties
       dirs_ignore        = {}   %(cell array), full names of directories to ignore ...
       first_chars_ignore = '.'  %(string)
    end
    
    methods
        function set.first_chars_ignore(obj,value)
           assert(ischar(value),'Input must be a character array')
           obj.first_chars_ignore = sl.str.quick.unique(value);
        end
        function set.dirs_ignore(obj,value)
           if ischar(value)
               value = {value};
           end
           %Sort for quicker ismember results ...
           obj.dirs_ignore = unique(value);
        end
        function s = getStruct(obj)
           s = sl.obj.toStruct(obj); 
        end
    end
    
end

