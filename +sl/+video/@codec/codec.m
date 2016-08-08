classdef (Abstract,Hidden) codec < sl.obj.handle_light
    %
    %   Class:
    %   sl.video.codec
    %
    %   This is an abstract class
    
    properties
    end
    
    methods (Abstract)
        output_data = decodeFrame(input_data)
    end
    
end

