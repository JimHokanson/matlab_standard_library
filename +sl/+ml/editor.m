classdef (Hidden) editor < sl.obj.display_class
    %
    %   Class:
    %   sl.editor.interface
    %
    %   This class is meant as an interface to the editor API that Matlab
    %   created in version (???). It was originally created to facilitate
    %   knowing if files had been edited in the editor and to help
    %    
    %   e = sl.ml.editor.getInstance();
    %
    %
    %   See Also:
    %   sl.ml.editor.document
    %   matlab.desktop.editor.Document
    %   matlab.desktop.editor
    
    
    %   Work with all documents open in the Editor:
    %     isEditorAvailable     - Verify Editor is available.
    %     DONE getAll                - Identify all open Editor documents.
    %
    %   Work with single document open in the Editor:
    %     DONE getActive             - Find active Editor document.
    %     DONE getActiveFilename     - Find file name of active document.
    %     findOpenDocument      - Create Document object for open document.
    %     isOpen                - Determine if specified file is open in Editor.
    %
    %   Open an existing document or create a new one:
    %     newDocument           - Create Document in Editor.
    %     openDocument          - Open file in Editor.
    %     openAndGoToFunction   - Open MATLAB file and highlight specified function.
    %     openAndGoToLine       - Open file and highlight specified line.
    %
    %   Work with text from an Editor document:
    %     indexToPositionInLine - Convert text array index to position within line.
    %     positionInLineToIndex - Convert position within line to text array index.
    %     linesToText           - Convert cell array of text lines to character array.
    %     textToLines           - Convert character array into cell array of text lines.
    
    
    
    
    properties (Dependent)
        active_filename %full path to document open in editor
        %? - what happens in split mode?
        %? - 
    end
    
    methods
        function value = get.active_filename(~)
           value = matlab.desktop.editor.getActiveFilename();
        end
    end
    
    methods (Access = private)
        function obj = editor()
            %Nothing so far ...
        end
    end
    
    methods
        function  output = getActiveDocument(~)
            %
            %   output = getActiveDocument(~)
            %
            %   obj = sl.editor.interface.getInstance
            %   output = obj.getActiveDocument();
            %
            %   Outputs:
            %   --------
            %   output: sl.ml.editor.document
            
            temp = matlab.desktop.editor.getActive;
            output = sl.ml.editor.document(temp);
        end
        function output = getAllDocuments(~)
            %
            %    Returns an array with document properties ...
            %
            %   TODO: pass into our constructor
            
            %Really, a pause? Bypassing call to getAll with
            %direct call to function doing the work ...
            output = matlab.desktop.editor.Document.getAllOpenEditors;
        end
    end
    
    
    methods (Static)
        function output = getInstance()
            %x Access method for singleton
            persistent local_obj
            if isempty(local_obj)
                local_obj = sl.ml.editor();
            end
            output = local_obj;
        end
    end
    
    methods (Static)
        function openAndGoToLine()
            matlab.desktop.editor.openAndGoToLine
        end
    end
    
end

