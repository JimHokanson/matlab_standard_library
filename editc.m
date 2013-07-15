function editc(class_name)
%editc  Edit a class in the editor
%   
%   editc(class_name)
%
%   editc -> edit class
%   
%   IMPROVEMENTS
%   =======================================================================
%   1) I want to modify tab complete so that it only provides tab complete
%   for classes with this file
%
%   Currently properties get edited before classes with the same name
%
%   +NEURON/+simulation/@options <- I want this
%   +NEURON/@simulation -> property 'options' <- gets opened

class_path = which(class_name);

matlab.desktop.editor.openDocument(class_path);