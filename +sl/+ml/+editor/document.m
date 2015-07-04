classdef document < sl.obj.display_class
    %
    %   Class:
    %   sl.ml.editor.document
    
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
        
        
        text
        selection_start_row
        selection_start_column
        selection_end_row
        selection_end_column
        selected_text
        modified
        editable
        line_count
    end
    
    methods
        function value = get.opened(obj)
            value = obj.h.Opened;
        end
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
        function value = get.modified(obj)
            value = obj.h.Modified;
        end
        function value = get.editable(obj)
            value = obj.h.Editable;
        end
        function value = get.line_count(obj)
           value = length(strfind(obj.text,sprintf('\n'))) + 1; 
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
        function gotoFunction(obj,fcn_name)
            
        end
        function gotoPositionInLine(obj,line,position)
            
        end
        function gotoLine(obj,line)
            
        end
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

