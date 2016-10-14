classdef (Hidden) keyboard_event_data < event.EventData
    %
    %   Class:
    %   sl.os.keyboard_event_data
    %
    %   See Also:
    %   sl.os.keyboard_logger
    %   

    properties
       s %struct, with the following fields:
       %TODO: Describe
    end
    
    methods (Static)
        function title_string = getTitleStringOfActiveWindow()
            title_string = sl.os.user32.getActiveWindowTitle();
        end
    end
    
end

