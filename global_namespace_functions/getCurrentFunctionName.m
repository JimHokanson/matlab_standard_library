function getCurrentFunctionName(input_args)
%getCurrentFunctionName
%Create shortcut for creating the name of a file in the editor #37

e = sl.ml.editor.getInstance();
temp = e.getActiveDocument();
file_path = temp.filename

fpi = sl.obj.file_path_info(file_path)


end

