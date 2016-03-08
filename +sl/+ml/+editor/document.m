classdef document < sl.obj.display_class
    %
    %   Class:
    %   sl.ml.editor.document
    %
    %   This class represents a programmatic interface to a document
    %   in the Matlab editor. 
    %
    %   Code in this class may not be reliable across different 
    %   versions of Matlab.
    %
    %   See Also:
    %   ---------
    %   sl.ml.editor.getInstance
    
    %   Work with text from an Editor document:
    %     indexToPositionInLine - Convert text array index to position within line.
    %     positionInLineToIndex - Convert position within line to text array index.
    %     linesToText           - Convert cell array of text lines to character array.
    %     textToLines           - Convert character array into cell array of text lines.
    
    properties (Hidden)
        h %matlab.desktop.editor.Document
    end
    
    properties
        filename
        language
    end
    %{
    ? line count
    ? get line text
    %}
    
    properties (Dependent)
        
        %This is not present in mac 2013a
        %opened %? What does this even mean?
        
        
        text %This appears to be all of the text in the document
        %and gets updated as you type into it
        
        selection_start_row
        selection_start_column
        selection_end_row
        selection_end_column
        selected_text
        line_text_up_to_cursor %all text up to the cursor on the current line
        cursor_line_text %all text on the line of the cursor
        modified
        editable
        line_ending_indices
        line_count
    end
    
    methods
        %Not present in mac 2013a
        %I think this means whether or not it is in the editor
        %and I think I could get this functionality out of older code
        %if I really wanted to via com calls
%         function value = get.opened(obj)
%             value = obj.h.Opened;
%         end
        function value = get.text(obj)
            value = obj.h.Text;
        end
        function value = get.selection_start_row(obj)
            value = obj.h.Selection(1);
        end
        function value = get.selection_start_column(obj)
            value = obj.h.Selection(2);
        end
        function value = get.selection_end_row(obj)
            value = obj.h.Selection(3);
        end
        function value = get.selection_end_column(obj)
            value = obj.h.Selection(4);
        end
        function value = get.selected_text(obj)
            
            %TODO: This looks like it is a methow now ...
            local_text = obj.text;
            start_row = obj.selection_start_row;
            start_column = obj.selection_start_column;
            end_row = obj.selection_end_row;
            end_column = obj.selection_end_column;
            
            if start_row == 1
                start_index = start_column;
            else
                start_index = local_line_indices(start_row-1) + start_column;
            end
            
            if end_row == 1
                end_index = end_column;
            else
                end_index = local_line_indices(end_row-1) + end_column;
            end
            
            value = local_text(start_index:end_index);
        end
        function value = get.line_text_up_to_cursor(obj)
            local_text = obj.text;
            start_row = obj.selection_start_row;
            local_line_indices = obj.line_ending_indices;
            if start_row == 1
                start_index = 1;
            else
                start_index = local_line_indices(start_row-1) + 1;
            end
            
            end_index = start_index+obj.selection_start_column-1;
            
            value = local_text(start_index:end_index); 
        end
        function value = get.cursor_line_text(obj)
            local_text = obj.text;
            start_row = obj.selection_start_row;
            local_line_indices = obj.line_ending_indices;
            if start_row == 1
                start_index = 1;
                if isempty(local_line_indices)
                    end_index = length(local_text);
                else
                    end_index = local_line_indices(1);
                end
            else
                start_index = local_line_indices(start_row-1) + 1;
                end_index = local_line_indices(start_row) - 1;
            end
            value = local_text(start_index:end_index);
        end
        function value = get.modified(obj)
            value = obj.h.Modified;
        end
        function value = get.editable(obj)
            value = obj.h.Editable;
        end
        function value = get.line_ending_indices(obj)
           value = strfind(obj.text,sprintf('\n')); 
        end
        function value = get.line_count(obj)
           value = length(obj.line_ending_indices) + 1; 
        end
    end
    
    methods
        function obj = document(ml_doc)
            %
            %   Inputs:
            %   -------
            %   ml_doc : matlab.desktop.editor.Document
            %
            %   See Also:
            %   ---------
            %   sl.editor.interface
            %
            
            obj.h = ml_doc;
            
            %TODO: This could be dynamic. When it is deleted from disk
            %the document becomes untitled
            obj.filename = ml_doc.Filename;
            
            obj.language = ml_doc.Language;
        end
% % % %         function gotoFunction(obj,fcn_name)
% % % %             
% % % %         end
% % % %         function gotoPositionInLine(obj,line,position)
% % % %             
% % % %         end
% % % %         function gotoLine(obj,line)
% % % %             
% % % %         end

        %All functions in h
        %------------------
        % appendText                  
        %   eq                          
        % goToPositionInLine          
        %makeActive                  
        %saveAs
        % close                       
        % goToFunction                
        %   insertTextAtPositionInLine  
        % reload                      
        %   setdiff
        % closeNoPrompt               
        %   goToLine 
        %    - overshooting goes to the last line
        %
        %   isequal                     
        %   save                        
        %   smartIndentContents
        
    end
    
end

