classdef obj
    %
    %   Class:
    %   sl.obj
    %
    %   Holds simple static methods for object related functionality
    
    properties
    end
    
    methods (Static)
        function name = getClassNameWithoutPackages(class_name)
            %x Returns name of the class, removing package prefixes if present
            %
            %    name = sl.obj.getClassNameWithoutPackages(class_name)
            %
            %    Example:
            %    --------
            %    obj = temp.package.my_object()
            %    name = sl.obj.getClassNameWithoutPackages(class(obj))
            %
            %    name => 'my_object'
            %
            %    %VERSUS:
            %
            %    class(obj)
            %    temp.package.my_object

            I   = strfind(class_name,'.');
            if isempty(I)
                name = class_name;
            else
                name = class_name((I(end)+1):end);
            end
        end
        function output = getFullMethodName(obj,method_name_or_names)
            %x Adds on packages and class name to method name
            %
            %   Calling Forms:
            %   --------------
            %   output = sl.obj.getFullMethodName(obj,method_name_or_names)
            %
            %   output = sl.obj.getFullMethodName(class_name,method_name_or_names)
            %
            %   Inputs:
            %   -------
            %   obj : Matlab Object
            %       Object from which the names should be referenced.
            %   class_name : string
            %       Full name of the class
            %   method_name_or_names :
            %
            %   Example:
            %   --------
            %   obj = adinstruments.channel()
            %
            %   m = methods(obj)
            %   m(1) => 'getAllData'
            %
            %   output = getFullMethodName(obj,'getAllData')
            %   output => 'adinstruments.channel.getAllData'
            %
            
            if ischar(obj)
               class_name = obj;
            else
               class_name = class(obj); 
            end
            
            if ischar(method_name_or_names)
                output = [class_name '.' method_name_or_names];
            else
                output = cellfun(@(x) [class_name '.' x],method_name_or_names,'un',0);
            end
        end
    end
    
end

