function docs = getUnsavedDocuments()
%
%   
%   sl.editor.getUnsavedDocuments()
%
%   See Also:
%   matlab.desktop.editor.Document

obj      = sl.editor.getInstance;
all_docs = obj.getAllDocuments();

modified = [all_docs.Modified];

docs     = all_docs(modified);