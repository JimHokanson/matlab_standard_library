classdef (Hidden) set < sl.mlint
    %
    %   Class:
    %   mlintlib.set
    %
    
    %No idea what this stuff means ...

    properties

    end
    
    methods
        function obj = set(file_path)
            
            obj.file_path      = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-set','-m3');
            
            keyboard
        end
    end
    
end

