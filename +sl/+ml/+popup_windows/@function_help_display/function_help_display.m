classdef function_help_display < handle
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
    %
    %   Features
    %   --------
    %   1) Display help for current input
    %   2) Display whether or not in debug mode, allow clicking to go
    %   to debug location
    %   3) Display whether busy or not
    %   4) Allow running selected code
    %   5) Allow running selected comment (as code, i.e. remove comment)
    
    properties
        fig %figure handle
        %TODO: Would prefer fig_h
        
        text_h
        t %The timer
        cmd_window %sl.ml.cmd_window
        
        %Can this ever become invalidated?
        editor %sl.ml.editor
        
        desktop %sl.ml.desktop
        
        last_focus = '' %editor,command window
    end
    
    methods
        function obj = function_help_display()
            
            %
            %
            %
            
            FIGURE_HANDLE = 3894576; %This shouldn't be necessary
            %but I had some luck with it
            
            %How often the code runs ...
            TIMER_PERIOD = 1;
            
            %I think I'll load this from a GUI
            %=> change text size buttons
            %=>
            
            %TODO: Create a figure
            %Eventually I'll probably want to load a pre created figure
            %from disk
            f = figure(FIGURE_HANDLE);
            obj.fig = f;
            
            set(f,'HandleVisibility','off')
            obj.text_h = uicontrol(f,'Style','text',...
                'Units','normalized',...
                'Position',[0.05 0.05 0.90 0.90],...
                'String','testing',...
                'BackgroundColor',[1 1 1],...
                'FontSize',12,...
                'HorizontalAlignment','left',...
                'Parent',f);
            
            %disp(obj.text_h)
            
            set(f,'CloseRequestFcn',@(~,~)cb_closeFigure(obj))
            
            %TODO: On close figure, stop timer and delete obj
            
            obj.cmd_window = sl.ml.cmd_window.getInstance();
            obj.editor = sl.ml.editor.getInstance();
            obj.desktop = sl.ml.desktop.getInstance();
            
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
            else
                obj.t
            end
        end
        function cb_closeFigure(obj)
            disp('close is running')
            delete(obj.fig)
            delete(obj)
        end
        function update_main_text(obj,text_to_display)
            set(obj.text_h,'String',text_to_display)
        end
    end
    
    methods (Static)
        %         uicontrol('Style','edit','String','hello');
        
        function varargout = launch()
            %
            %   sl.ml.popup_windows.function_help_display.launch
            %
            %   When debugging:
            %   obj = sl.ml.popup_windows.function_help_display.launch
            
            persistent local_obj
            %if isempty(local_obj) || (isvalid(local_obj) && ~ishandle(local_obj.fig))
            if isempty(local_obj) || ~isvalid(local_obj) || ~ishandle(local_obj.fig)
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
            
            
            try
                
                %We'll eventually want to persist some of the results
                %so that we don't call expensive update functions
                %
                %persistent last_location
                                
                %TODO: This needs to be a more appropriate check
                %we might have made a new figure that is posing as the old
                %one
                %
                %See Also:
                %http://stackoverflow.com/questions/1956626/checking-if-a-matlab-handle-is-a-valid-one
                if ~ishandle(obj.fig)
                    %Figure closed
                    %TODO: Does this run again, I would think we stop the
                    %timer so this would only run once
                    %TODO: delete obj
                    return
                elseif obj.desktop.is_busy
                    %TODO: This will actually go elsewhere ...
                    obj.update_main_text('Analysis paused during code execution')
                    return
                end
                
                %TODO: Build in support for better timer debugging
                %http://www.mathworks.com/matlabcentral/answers/65694-debug-code-invoked-by-timer
                
                
                %Added 'local' to avoid warning on possibly meaning to access
                %property name
                
                
                
                %Determine if we are showing help fo the command line
                %or the editor
                if local_cw.has_focus                    
                    obj.last_focus = 'command window';
                    %h__getCLIFromCW
                    cli = h__getCLIFromCW(obj);
                elseif local_editor.has_focus
                    obj.last_focus = 'editor';
                    cli = h__getCLIFromEditor(obj);
                elseif strcmp(obj.last_focus,'command window')
                    cli = h__getCLIFromCW(obj);
                else
                    cli = h__getCLIFromEditor(obj);
                end
                
                %cli = sl.help.current_line_info(last_line_text);
                %TODO
                 
                obj.update_main_text(line_text);
                
                
            catch ME
                %This is temporary while I write the code
                fprintf(2,'Encountered an error in the timer callback\n');
                keyboard
                disp('Error occurred in sl.ml.popup_windows.function_help_display')
            end
            
        end
        
    end
    
end

function cli = h__getCLIFromCW(obj)
%sl.ml.cursor_line_info
%TODO: Build in selection as well, not just start of the cursor
local_cw = obj.cmd_window; %Type: %sl.ml.cmd_window
line_text = local_cw.line_text_up_to_cursor;
cli = sl.ml.cursor_line_info(true,[],line_text);

end

function cli = h__getCLIFromEditor(obj)
active_doc = obj.editor.getActiveDocument();
line_text = active_doc.line_text_up_to_cursor;
cli = sl.ml.cursor_line_info(false,active_doc,line_text);
end

