classdef cmd_window < sl.obj.display_class
    %
    %   Class:
    %   sl.cmd_window
    %
    %   Run via:
    %   --------
    %   c = sl.ml.cmd_window.getInstance()
    %
    %   TODO:
    %   -----
    %   1) Can we get focus - for goDebug
    %
    %
    %   Very few methods have been exposed. Some interesting ones include:
    %   - getMouseListeners
    %   - getKeyListeners
    %   -
    
    %{
    getLineEndOffset - this seems to be pixel based not char based
    getLineOfOffset - goes from a char position to a line #
    getRows - doesn't seem to work
    %}
    
    properties (Hidden)
        h %com.mathworks.mde.cmdwin.CmdWin
        h_text %com.mathworks.mde.cmdwin.XCmdWndView
    end
    
    properties (Dependent)
        selection_start %In absolute characters, not row column
        %When nothing is selected, this seems to identify the last
        %character
        selection_end
        line_count
        has_focus
        last_line_text
%         cursor_on_last_line
    end
    
    methods
        function value = get.selection_start(obj)
           value = obj.h_text.getSelectionStart();
        end
        function value = get.selection_end(obj)
           value = obj.h_text.getSelectionEnd(); 
        end
        function value = get.line_count(obj)
           value = obj.h_text.getLineCount(); 
        end
        function value = get.has_focus(obj)
           value = obj.h_text.hasFocus(); 
        end
%         function value = get.cursor_on_last_line(obj)
%            value = obj.line_count == obj.h_text.getLineOfOffset(obj.selection_start);
%         end
    end
    
    methods
        function text = getText(obj,start_char,end_char)
            %
            
            %   Internal function:
            %   getText() - 0 based
            %   returns carets ...
            
            n_chars = end_char-start_char+1;
            
            if nargin
                text = char(obj.h_text.getText(start_char-1,n_chars)); 
            else
                text = char(obj.h_text.getText());
            end
        end
        function line_text = getLineText(obj,line_number)
            %
            %
            
            %   Internal notes:
            %   getLineStartOffset => line number is 0 based
            
           %I think these 2 functions don't always work ...
           start_I = obj.h_text.getLineStartOffset(line_number-1);
           end_I = obj.h_text.getLineEndOffset(line_number-1);
           line_text = char(obj.h_text.getText(start_I,end_I-start_I+1));
        end
    end

    methods (Access = private)
        function obj = cmd_window()
            
            %obj.h = com.mathworks.mde.cmdwin.cmdWinDocument.getInstance;
            obj.h = com.mathworks.mde.cmdwin.CmdWin.getInstance;
            obj.h_text = h__getTextReference(obj.h);
            
        end
    end
    
    methods (Static)
        function output = getInstance()
            %x Access method for singleton
            persistent local_obj
            if isempty(local_obj)
                local_obj = sl.ml.cmd_window;
            end
            output = local_obj;
        end
    end
    methods (Static)
        function n_chars_max = getMaxCharsBeforeScroll()
            %
            %
            %    n_chars_max = sl.cmd_window.getMaxCharsBeforeScroll
            %
            %    Returns the maximum # of characters that can be displayed
            %    in the command window before scrolling will occur
            %
            %    ??? Does this change if the font size changes?????
            %
            %
            
            %TODO: Allow version checking and using:
            %matlab.desktop.commandwindow.size
            
            %From root properties documentation:
            %            CommandWindowSize
            % [columns rows]
            %
            % Note:   The CommandWindowSize root property will be removed in a future
            % release. To determine the number of columns and rows that display in the
            % Command Window, given its current size, call
            % matlab.desktop.commandwindow.size. Current size of command window. Size
            % of the MATLAB® command window, in a two-element vector. The first element
            % is the number of columns wide and the second element is the number of
            % rows tall.
            %
            % For example, a value of [50,25] means that 50 characters can display
            % across the Command Window, and 25 lines can display without scrolling.
            %
            % Enabling the Command Window Display preference Set matrix display width
            % to eighty columns forces the returned value for number of columns wide to
            % be 80 regardless of the window width.
            
            cmd_win_sizes = get(0,'CommandWindowSize');
            %Has 2 elements:
            %1) # of chars for width
            %2) # of lines????
            
            n_chars_max = cmd_win_sizes(1)-1; %NOTE: If we don't use -1 then
            %the scroll bar will appear (at least in 2014a)
        end
        
        
    end
    
end

function h_text = h__getTextReference(h_cmd)
%
%
%   Code based on:
%   http://www.mathworks.com/matlabcentral/fileexchange/31438-command-window-text


cmd_window_components = get(h_cmd,'Components');
sub_components =get(cmd_window_components(1),'Components');
% java.awt.Component[]:
%     [javax.swing.JViewport            ]
%     [javax.swing.JScrollPane$ScrollBar]
%     [javax.swing.JScrollPane$ScrollBar]
sub_sub_components =get(sub_components(1),'Components');
% java.awt.Component[]:
%     [com.mathworks.mde.cmdwin.XCmdWndView]

h_text = sub_sub_components(1);

end
