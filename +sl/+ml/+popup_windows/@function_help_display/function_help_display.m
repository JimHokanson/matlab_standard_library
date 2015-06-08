classdef function_help_display
    %
    %   Class:
    %   sl.ml.popup_windows.function_help_display
    %
    %   The goal of this class will be to show help for the command window
    %   or editor, depending on where the cursor is located.
    %
    %   This should be implemented as a figure ...
    %
    %   TODO:
    %   -----
    %   1) Launch a figure that periodically runs a function (to update
    %   the display)
    %       - can we tell when a program is running - and stop execution
    %       -
    %
    %   1) Create figure with display text. 
    %   2) On close, destroy the object.
    %
    %   See Also:
    %   sl.help.current_line_info
    
    properties
        t %The timer
        cmd_window
    end
    
    methods
        function obj = function_help_display()
            
            %
            %
            %
            
            %TODO: Create a figure 
            
            obj.cmd_window = sl.ml.cmd_window.getInstance();
            
            %Create and start the timer
            fh = @(~,~)sl.ml.popup_windows.function_help_display.cb__updateHelpText(obj);
            obj.t = timer('TimerFcn',fh,'ExecutionMode','fixedSpacing',...
                'Period',5);
            start(obj.t)
        end
    end
    
    methods (Static)
        %         uicontrol('Style','edit','String','hello');
        
        function launch()
            %
            %   sl.ml.popup_windows.function_help_display.launch
            %
            
            persistent local_obj
            if isempty(local_obj)
                local_obj = sl.ml.popup_windows.function_help_display;
            end
            % % %            output = local_obj;
            % % %            obj =
            % % %            t = timer;
        end
        function cb__updateHelpText(obj)
            %
            %
            
            cw = obj.cmd_window;
            last_line_text = cw.getLineText(cw.line_count);
            fprintf(2,'Last line\n')
            disp(last_line_text)
            
        end
    end
    
end

