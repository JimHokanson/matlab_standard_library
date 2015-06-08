classdef (Hidden) interface < sl.obj.display_class
    %
    %   Class:
    %   sl.editor.interface
    %
    %   This class is meant as an interface to the editor API that Matlab
    %   created in version (???). It was originally created to facilitate
    %   knowing if files had been edited in the editor and to help 
    %
    %
    %   See Also:
    %   matlab.desktop.editor.Document
    %   matlab.desktop.editor
    
    
%   Work with all documents open in the Editor:
%     isEditorAvailable     - Verify Editor is available.
%     getAll                - Identify all open Editor documents.
%  
%   Work with single document open in the Editor:
%     getActive             - Find active Editor document.
%     getActiveFilename     - Find file name of active document.
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
    
    
    
    
    properties
    end
    
    methods (Access = private)
        function obj = interface()
           %Nothing so far ... 
        end
    end
    
    methods
        %NOTE: This returns a class ...
        %Wrap in our own class?????
        %
        %Yes ...
        function  output = getActiveDocument(~)
            %
            %   output = getActiveDocument(~)
            %
            %   obj = sl.editor.interface.getInstance
            %   output = obj.getActiveDocument();
            %
            %   Outputs:
            %   --------
            %   output: Class: matlab.desktop.editor.Document 
            
            
%         Filename: 'C:\D\repos\matlab_git\mat_std_lib\+sl\+editor\interface.m'
%           Opened: 1
%         Language: 'MATLAB'
%             Text: [1x2313 char]
%        Selection: [50 17 50 50]
%     SelectedText: 'output = obj.getActiveDocument();'
%         Modified: 0
%         Editable: 1
            
            
            
            
            
            output = matlab.desktop.editor.getActive; 
        end
        function output = getAllDocuments(~)
           %
           %    Returns an array with document properties ...
           %    
           
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
               local_obj = sl.ml.editor.interface;
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

