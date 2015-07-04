classdef function_help_display
    %
    %   Class: (Singleton)
    %   sl.ml.popup_windows.function_help_display
    %
    %   Call via:
    %   ---------
    %   sl.ml.popup_windows.function_help_display.launch
    %
    %   The goal of this class will be to show help for the command window
    %   or editor, depending on where the cursor is located.
    %
    %   Status:
    %   -------
    %   I'm currently working 
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
        fig %figure handle
        %TODO: Would prefer fig_h
        
        text_h
        t %The timer
        cmd_window %sl.ml.cmd_window
        editor
    end
    
    methods
        function obj = function_help_display()
            
            %
            %
            %
            
            TIMER_PERIOD = 1;
            
            %I think I'll load this from a GUI
            %=> change text size buttons
            %=> 
            
            %TODO: Create a figure 
            f = figure;
            obj.fig = f;
            
            set(f,'HandleVisibility','off')
            obj.text_h = uicontrol(f,'Style','text','Units','normalized','Position',...
                [0.05 0.05 0.90 0.90],'String','testing',...
                'BackgroundColor',[1 1 1],'FontSize',12,'HorizontalAlignment','left');
            
            set(f,'CloseRequestFcn',@(~,~)cb_closeFigure(obj))
            
            %TODO: On close figure, stop timer and delete obj
            
            obj.cmd_window = sl.ml.cmd_window.getInstance();
            obj.editor = sl.ml.editor.getInstance();
            
            %Create and start the timer
            fh = @(~,~)sl.ml.popup_windows.function_help_display.cb__updateHelpText(obj);
            obj.t = timer('TimerFcn',fh,'ExecutionMode','fixedSpacing',...
                'Period',TIMER_PERIOD);
            start(obj.t)
        end
        function delete(obj)
           %try 
               %disp('Delete ran')
           if isa(obj.t,'timer')
               stop(obj.t)
               delete(obj.t)
           end
        end
        function cb_closeFigure(obj)
           delete(obj.fig)
           delete(obj)
        end
    end
    
    methods (Static)
        %         uicontrol('Style','edit','String','hello');
        
        function varargout = launch()
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
            
            %This is primarily for debugging
            if nargout
               varargout{1} = local_obj; 
            end
        end
        function cb__updateHelpText(obj)
            %
            %
            
            %TODO: This needs to be a more appropriate check
            %See Also:
            %http://stackoverflow.com/questions/1956626/checking-if-a-matlab-handle-is-a-valid-one
            if ~ishandle(obj.fig)
               %Figure closed, delete obj
               %stop(obj.t)
%                delete(obj.t)
%                delete(obj)
               return
            end
            

            
            %TODO: Build in support for better timer debugging
            %http://www.mathworks.com/matlabcentral/answers/65694-debug-code-invoked-by-timer
            
            try
            %sl.ml.cmd_window
            cw = obj.cmd_window;
            editor = obj.editor;
            %Determine if we are showing help fo the command line
            %or the editor
            if cw.has_focus
               last_line_text = cw.getLineText(cw.line_count);
            elseif editor.has_focus
               %TODO: check if editor has focus, otherwise allow a user
               %setabble default via launch
               %
               %get last editor text 
               last_line_text = 'editor has focus';
            else
               last_line_text = 'unknown focus';
            end
            
            cli = sl.help.current_line_info(last_line_text);
            
            %fprintf(2,'Last line\n')
            %disp(last_line_text)
            set(obj.text_h,'String',last_line_text)
            
            catch
               disp('Error occurred in sl.ml.popup_windows.function_help_display') 
            end
            
        end
    end
    
end

