classdef cursor_line_info < handle
    %
    %   Class:
    %   sl.ml.cursor_line_info
    %
    %   This class is meant to be passed to the help function (name?)
    %   that will interpret what I have currently typed to provide
    %   help related to that typing
    %
    %   See Also:
    %   sl.ml.popup_windows.function_help_display.launch
    %   sl.ml.parsed_cursor_line_info
    %
    %   TODO: 
    %   -----
    %   Build method that will call parsed_cursor_line_info
    
    properties
       from_command_window
       active_document
       cursor_column_index %TODO: How do I want to # this since
       %the cursor exists between letters
       %0 - beginning of line
       %1 - 1 character before the cursor
       pre_cursor_text
    end
    
    methods
        function obj =  cursor_line_info(from_command_window,active_document,cursor_column_index,pre_cursor_text)
           obj.from_command_window = from_command_window;
           obj.active_document = active_document;
        end
    end
    
end

