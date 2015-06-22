function editc(class_name_or_object)
%editc  Edit a class name or instance in the editor
%
%   Calling Forms:
%   -----------------
%   1) 
%       editc(class_name)
%
%   2) 
%       edtic(class_instance)
%   
%
%   editc => "edit class"
%
%   Why does this function exist?:
%   ------------------------------
%   The edit() function is an ambiguous request as a name does not fully
%   resolve the file path. Specifically a property and class can have the
%   same name.
%
%   For example, consider:
%       Neuron.simulation.options
%
%   This is either:
%   1) A class Neuron.simulation with a PROPERTY options 
%   2) a CLASS or FUNCTION options in the Neuron.simulation package. 
%
%   Both can exist but which should edit() open?
%
%   +NEURON/+simulation/@options <- I want this, note @ refers to class
%   +NEURON/@simulation => property 'options' <- gets opened
%
%   Inputs:
%   -------
%   class_name: string or object
%   class_instance : instance of a Matlab object
%
%   Improvements:
%   -------------
%   1) It would be nice to modify tab complete so that it only provides 
%   tab complete for classes with this file


if isobject(class_name_or_object)
    class_name = class(class_name_or_object);
else
    class_name = class_name_or_object;
end

%Which resolves the class or function rather than the property.
class_path = which(class_name);

if isempty(class_path)
    %This generally happens when I call editc <class_instance>
    %instead of editc(class_instance)
    error('Class name couldn''t be resolved to a file')
end

matlab.desktop.editor.openDocument(class_path);