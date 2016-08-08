classdef (Hidden) editor < sl.obj.display_class
    %
    %   Class: (Singleton)
    %   sl.ml.editor
    %
    %   This class is meant as an interface to the editor API that Matlab
    %   created in version (???). It was originally created to facilitate
    %   knowing if files had been edited in the editor and to help
    %    
    %   Call via:
    %   ---------
    %   e = sl.ml.editor.getInstance();
    %
    %   See Also:
    %   ---------
    %   sl.ml.editor.document
    %   matlab.desktop.editor.Document
    %   matlab.desktop.editor
    %
    %
    %   Status:
    %   -------
    %   The "API" version provided as of ... isn't all that exciting.
    %
    %   TODO:
    %   -----
    %   Incorporate com.mathworks.mde.desk.MLDesktop.getInstance and 
    %   hasFocus
    
    
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
    
    %{
    Undocumented:
    wtf = com.mathworks.mlservices.MLEditorServices.getEditorApplication
    com.mathworks.mde.editor.MatlabEditorApplication
    
    d = com.mathworks.mlservices.MLEditorServices;
    fName = d.builtinGetActiveDocument;
    path=fileparts(fName.toCharArray');
    
    %e is Java Collection (List?) on documents
    e = wtf.getOpenEditors
    e.size %# of documents
    wtf2 = e.get(#)
    
    wtf2 : com.mathworks.mde.editor.MatlabEditor
    wtf2.getLongName
    wtf2.smartIndentContents
    %}
    
    
    properties
       main_frame_h %TODO: This might not be a valid approach
    end
    
    properties (Dependent)
        active_filename %full path to document open in editor
        %? - what happens in split mode?
        %? - 
        has_focus %This may not be correct
    end
    
    methods
        function value = get.active_filename(~)
           value = matlab.desktop.editor.getActiveFilename();
        end
        function value = get.has_focus(obj)
           %hasFocus doesn't seem to work, my guess is that it is too
           %specific, 
           value = obj.main_frame_h.isActive; 
        end
    end
    
    methods (Access = private)
        function obj = editor()
            %http://undocumentedmatlab.com/blog/accessing-the-matlab-editor
            temp = com.mathworks.mde.desk.MLDesktop.getInstance;
            obj.main_frame_h = temp.getGroupContainer('Editor').getTopLevelAncestor;
        end
    end
    
    methods
        function  output = getActiveDocument(~)
            %x Returns the currently selected document
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
            %TODO: This needs to be completed
            %
            %Allow defaults of using current file and/or current line number   
            matlab.desktop.editor.openAndGoToLine
        end
    end
    
end

