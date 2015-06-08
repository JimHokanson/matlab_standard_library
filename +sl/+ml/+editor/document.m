classdef document < sl.obj.display_class
    %
    %   Class:
    %   sl.ml.editor.document
    
    properties (Hidden)
       h %matlab.desktop.editor.Document
    end
    
    properties
       filename
       language
    end
    
    properties (Dependent)
       opened %? What does this even mean?
       text
       selection_start_row
       selection_start_column
       selection_end_row
       selection_end_column
       selection_text
       modified
       editable    
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
           obj.filename = ml_doc.Filename;
           obj.language = ml_doc.Language;
        end
% appendText                  eq                          goToPositionInLine          makeActive                  saveAs                      
% close                       goToFunction                insertTextAtPositionInLine  reload                      setdiff                     
% closeNoPrompt               goToLine                    isequal                     save                        smartIndentContents         

    end
    
end

