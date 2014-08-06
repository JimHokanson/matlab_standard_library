function editc(class_name_or_object)
%editc  Edit a class in the editor
%
%   editc(class_name)
%
%   editc -> "edit class"
%
%   The edit() function is an ambiguous request as a name does not fully
%   resolve the file path. Specifically a property and class can have the
%   same name.
%
%   e.g. Neuron.simulation.options
%
%   This is either a class Neuron.simulation with a PROPERTY options and/or
%   a CLASS or FUNCTION options in the Neuron.simulation package. Both can
%   coexist but which should edit() open?
%
%   +NEURON/+simulation/@options <- I want this
%   +NEURON/@simulation -> property 'options' <- gets opened
%
%
%
%   Inputs:
%   -------
%   class_name_or_object: string or object
%
%   IMPROVEMENTS
%   =======================================================================
%   1) I want to modify tab complete so that it only provides tab complete
%   for classes with this file


if isobject(class_name_or_object)
    class_name = class(class_name_or_object);
else
    class_name = class_name_or_object;
end

class_path = which(class_name);

matlab.desktop.editor.openDocument(class_path);