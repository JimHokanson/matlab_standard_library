classdef charset
    %
    %   Class:
    %   sl.ml.charset.
    %
    %   I'm not thrilled with the class name
    %   Also, I am not completely sure what I want the code base to do
    %   other than store some notes at this point ...
    %
    %   get(0,'language')   
    %   feature('DefaultCharacterSet')
    %   feature('locale')
    %
    %   Command window doesn't always display the characters properly ...
    %   e.g. char(8057)
    
    %http://blogs.mathworks.com/loren/2006/09/20/working-with-low-level-file-io-and-encodings/
    
    properties
    end
    
    methods (Static)
        function set_value = setCurrent(new_value)
            feature('DefaultCharacterSet',new_value);
            current_charset = feature('DefaultCharacterSet');
        end
        function current_charset = getCurrent()
            current_charset = feature('DefaultCharacterSet');
        end
    end
    
end

